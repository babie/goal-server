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
    generations: 0,
  }
  @invalid_attrs %{}

  setup do
    user = fixture(:user)
    root = fixture(:root, user: user)
            |> Repo.preload(:descendant_tree)
            |> Repo.preload(:owner)
    [c1, c2, c3] = children = fixture(:children, parent: root)
    gcs1 = fixture(:children, parent: c1)
    gcs2 = fixture(:children, parent: c2)
    gcs3 = fixture(:children, parent: c3)
    {:ok, user: user, root: root, children: children, gcs1: gcs1, gcs2: gcs2, gcs3: gcs3}
  end

  test "changeset with valid attributes", %{user: user} do
    changeset = Goal.changeset(%Goal{}, Map.merge(@valid_attrs, %{owned_by: user.id, inserted_by: user.id, updated_by: user.id}))
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Goal.changeset(%Goal{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "get children", %{root: root, children: children} do
    children_ids = root |> Goal.Commands.children |> Enum.map(&(&1.id))
    assert children_ids == Enum.map(children, &(&1.id))
  end

  test "get parent", %{children: children, gcs2: gcs2} do
    [_c1, c2, _c3] = children
    [_gc1, gc2, _gc3] = gcs2
    parent = gc2 |> Goal.Commands.parent
    assert parent.id == c2.id
  end

  test "get siblings", %{children: children} do
    [c1, c2, c3] = children
    new_sibling_ids = c2 |> Goal.Commands.siblings |> Enum.map(&(&1.id))
    sibling_ids = [c1, c3] |> Enum.map(&(&1.id))
    assert new_sibling_ids == sibling_ids
  end
end
