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
    [root, c1, c2, c3] = [root, c1, c2, c3] |> Enum.map(&(Repo.preload(&1, [:children, :owner])))
    
    {:ok, user: user, root: root, children: [c1, c2, c3], gcs1: gcs1, gcs2: gcs2, gcs3: gcs3}
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
    new_children_ids = root.children |> Enum.sort(&(&1.position < &2.position)) |> Enum.map(&(&1.id))
    children_ids = children |> Enum.map(&(&1.id))
    assert new_children_ids == children_ids
  end

  test "get parent", %{children: children, gcs2: gcs2} do
    [_c1, c2, _c3] = children
    [_gc1, gc2, _gc3] = gcs2
    parent = gc2.parent
    assert parent.id == c2.id
  end

  test "get siblings", %{children: children} do
    [c1, c2, c3] = children
    new_sibling_ids = c2 |> Goal.Commands.siblings |> Enum.map(&(&1.id))
    sibling_ids = [c1, c3] |> Enum.map(&(&1.id))
    assert new_sibling_ids == sibling_ids
  end
end
