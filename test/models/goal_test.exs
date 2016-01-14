defmodule GoalServer.GoalTest do
  use GoalServer.ModelCase
  import GoalServer.Fixtures

  alias GoalServer.Goal

  @valid_attrs %{body: "some content", status: "some content", title: "some content"}
  @invalid_attrs %{}
  setup do
    user = fixture(:user)
    root = fixture(:root, user: user)
    children = fixture(:children, root: root)
    {:ok, user: user, root: root, children: children}
  end

  test "changeset with valid attributes", %{user: user} do
    changeset = Goal.changeset(%Goal{}, Map.merge(@valid_attrs, %{owned_by: user.id, inserted_by: user.id, updated_by: user.id}))
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Goal.changeset(%Goal{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "root has children", %{root: root, children: children} do
    root = root |> Repo.preload(:children)
    assert root.children == children
  end
end
