defmodule GoalServer.GoalTest do
  use GoalServer.ModelCase
  import GoalServer.Fixtures

  alias GoalServer.Goal

  @valid_attrs %{
    title: "some content",
    body: "some content",
    status: "some content",
    position: 0,
    parent_id: nil,
  }
  @invalid_attrs %{}

  setup do
    user = fixture(:user)
    root = fixture(:root, user: user)
    [c1, c2, c3] = fixture(:children, parent: root)
    gcs1 = fixture(:children, parent: c1)
    gcs2 = fixture(:children, parent: c2)
    gcs3 = fixture(:children, parent: c3)
    
    {:ok, user: user, root: root, children: [c1, c2, c3], gcs1: gcs1, gcs2: gcs2, gcs3: gcs3}
  end

  test "changeset with valid attributes", %{user: user} do
    changeset = Goal.changeset(%Goal{}, Map.merge(@valid_attrs, %{user_id: user.id}))
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Goal.changeset(%Goal{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "get parent", %{children: children, gcs2: gcs2} do
    [_c1, c2, _c3] = children
    [_gc1, gc2, _gc3] = gcs2
    gc2 = gc2 |> Repo.preload(:parent)
    parent = gc2.parent
    assert parent.id == c2.id
  end

  test "get children", %{root: root, children: children} do
    root = root |> Repo.preload(:children)
    new_children_ids = root.children |> Enum.sort(&(&1.position < &2.position)) |> Enum.map(&(&1.id))
    children_ids = children |> Enum.map(&(&1.id))
    assert new_children_ids == children_ids
  end

  test "get siblings", %{children: children} do
    [c1, c2, c3] = children
    new_sibling_ids = c2 |> Goal.Queries.siblings |> Enum.map(&(&1.id))
    sibling_ids = [c1, c3] |> Enum.map(&(&1.id))
    assert new_sibling_ids == sibling_ids
  end

  test "get self_and_descendants", %{children: [_, c2, _], gcs2: [_, gcs2_2, _]} do
    gcs2_2_children = fixture(:children, parent: gcs2_2)
    [first|ds] = Goal.Queries.self_and_descendants(c2)
    assert first.id == c2.id
    assert length(ds) == 6
    Enum.each(gcs2_2_children, fn(g) ->
      assert Enum.any?(ds, fn(d) -> d.id == g.id end)
    end)
  end

  test "get descendants", %{children: [_, c2, _], gcs2: [_, gcs2_2, _]} do
    gcs2_2_children = fixture(:children, parent: gcs2_2)
    ds = Goal.Queries.descendants(c2)
    assert length(ds) == 6
    Enum.each(gcs2_2_children, fn(g) ->
      assert Enum.any?(ds, fn(d) -> d.id == g.id end)
    end)
  end

  test "insert", %{user: user, root: root, children: [c1, c2, c3]} do
    attrs = Map.merge(@valid_attrs, %{parent_id: root.id, position: 1, user_id: user.id})
    changeset = Goal.changeset(%Goal{}, attrs)
    {:ok, new} = Goal.Commands.insert(changeset)
    root = root |> Repo.preload(:children)
    new_children_ids = root.children |> Enum.sort(&(&1.position < &2.position)) |> Enum.map(&(&1.id))
    children_ids = [c1, new, c2, c3] |> Enum.map(&(&1.id))
    assert new_children_ids == children_ids
  end

  test "move position up", %{root: root, children: [c1, c2, c3]} do
    changeset = Goal.changeset(c2, %{position: 0})
    {:ok, new} = Goal.Commands.update(changeset)
    root = root |> Repo.preload(:children)
    new_children_ids = root.children |> Enum.sort(&(&1.position < &2.position)) |> Enum.map(&(&1.id))
    children_ids = [new, c1, c3] |> Enum.map(&(&1.id))
    assert new_children_ids == children_ids
  end

  test "move position down", %{root: root, children: [c1, c2, c3]} do
    changeset = Goal.changeset(c2, %{position: 3})
    {:ok, new} = Goal.Commands.update(changeset)
    root = root |> Repo.preload(:children)
    new_children_ids = root.children |> Enum.sort(&(&1.position < &2.position)) |> Enum.map(&(&1.id))
    children_ids = [c1, c3, new] |> Enum.map(&(&1.id))
    assert new_children_ids == children_ids
  end

  test "move subtree", %{root: root, children: [c1, c2, c3], gcs2: [_gcs2_1, gcs2_2, _gcs2_3]} do
    changeset = Goal.changeset(gcs2_2, %{parent_id: root.id, position: 1})
    {:ok, new} = Goal.Commands.update(changeset)
    root = root |> Repo.preload(:children)
    new_children_ids = root.children |> Enum.sort(&(&1.position < &2.position)) |> Enum.map(&(&1.id))
    children_ids = [c1, new, c2, c3] |> Enum.map(&(&1.id))
    assert new_children_ids == children_ids
  end

  test "can't move subtree", %{children: [_c1, c2, _c3], gcs2: [_gcs2_1, gcs2_2, _gcs2_3]} do
    fixture(:children, parent: gcs2_2)
    changeset = Goal.changeset(c2, %{parent_id: gcs2_2.id, position: 1})
    assert_raise ArgumentError, fn ->
      Goal.Commands.update(changeset)
    end
  end

  test "delete", %{root: root, children: [_c1, c2, _c3], gcs2: [_gcs2_1, gcs2_2, _gcs2_3]} do
    ds = fixture(:children, parent: gcs2_2)
    Repo.delete!(c2)
    all = Goal.Queries.self_and_descendants(root)
    Enum.each([c2|ds], fn(g) ->
      refute Enum.any?(all, fn(e) -> e.id == g.id end)
    end)
  end

  test "copy", %{root: root, gcs2: [_gcs2_1, gcs2_2, _gcs2_3]} do
    ds_titles = fixture(:children, parent: gcs2_2) |> Enum.map(&(&1.title))
    Goal.Commands.copy(gcs2_2, root.id, 1)
    
    root = root |> Repo.preload([:children])
    [_c1, copied, _c2, _c3] = root.children
                              |> Enum.sort(&(&1.position < &2.position))
    assert copied.title == gcs2_2.title
    assert copied.parent_id == root.id
    assert copied.position == 1

    copied_ds_titles = copied |> Goal.Queries.descendants |> Enum.map(&(&1.title))
    assert copied_ds_titles == ds_titles
  end

  test "copy into subtree", %{children: [_c1, c2, _c3], gcs2: [_gcs2_1, gcs2_2, _gcs2_3]} do
    fixture(:children, parent: gcs2_2)
    ds_titles = c2 |> Goal.Queries.descendants |> Enum.map(&(&1.title))
    Goal.Commands.copy(c2, gcs2_2.id,  1)
    
    gcs2_2 = gcs2_2 |> Repo.preload([:children])
    [_ggc1, copied, _ggc2, _ggc3] = gcs2_2.children
                                    |> Enum.sort(&(&1.position < &2.position))
    assert copied.title == c2.title
    assert copied.parent_id == gcs2_2.id
    assert copied.position == 1

    copied_ds_titles = copied |> Goal.Queries.descendants |> Enum.map(&(&1.title))
    assert copied_ds_titles == ds_titles
  end
end
