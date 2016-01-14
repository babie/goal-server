defmodule GoalServer.GoalTest do
  use GoalServer.ModelCase
  import GoalServer.Fixtures

  alias GoalServer.Goal

  @valid_attrs %{body: "some content", status: "some content", title: "some content"}
  @invalid_attrs %{}
  setup do
    user = fixture(:user)
    root = fixture(:root, user: user)
            |> Repo.preload(:goal_tree)
            |> Repo.preload(:owner)
    children = fixture(:children, parent: root)
    grandchildren = fixture(:children, parent: List.first(children))
    {:ok, user: user, root: root, children: children, grandchildren: grandchildren}
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
    children_ids = root |> Goal.Queries.children |> Repo.all |> Enum.map(&(&1.id))
    assert children_ids == Enum.map(children, &(&1.id))
  end

  test "get ancestor", %{children: children, grandchildren: grandchildren} do
    child = List.first children
    gchild = List.first grandchildren
    ancestor_id = gchild |> Goal.Queries.ancestor |> Repo.all |> Enum.map(&(&1.id))
    assert ancestor_id == [child.id]
  end

  test "get siblings", %{children: children} do
    [c1, c2, c3] = children
    sibling_ids = c2 |> Goal.Queries.siblings |> Enum.map(&(&1.id))
    assert sibling_ids == [c1.id, c3.id]
  end
end
