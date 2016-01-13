defmodule GoalServer.GoalTest do
  use GoalServer.ModelCase

  alias GoalServer.User
  alias GoalServer.Goal
  alias GoalServer.GoalTree

  @valid_attrs %{body: "some content", status: "some content", title: "some content"}
  @invalid_attrs %{}
  setup do
    user = Repo.insert! User.changeset(%User{}, %{nick: "some content"})
    root = Repo.insert! Goal.changeset(%Goal{}, %{
      title: "root",
      status: "root",
      owned_by: user.id,
      inserted_by: user.id,
      updated_by: user.id
    })
    child1 = Repo.insert! Goal.changeset(%Goal{}, %{
      title: "child1",
      status: "todo",
      position: 0,
      parent_id: root.id,
      owned_by: user.id,
      inserted_by: user.id,
      updated_by: user.id
    })
    child1_tree = Repo.insert! GoalTree.changeset(%GoalTree{}, %{
      ancestor_id: root.id,
      descendant_id: child1.id,
      generations: 0
    })
    child2 = Repo.insert! Goal.changeset(%Goal{}, %{
      title: "child2",
      status: "todo",
      position: 1,
      parent_id: root.id,
      owned_by: user.id,
      inserted_by: user.id,
      updated_by: user.id
    })
    child2_tree = Repo.insert! GoalTree.changeset(%GoalTree{}, %{
      ancestor_id: root.id,
      descendant_id: child2.id,
      generations: 0
    })
    {:ok, user: user, root: root, children: [child1, child2]}
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
    root_children = Enum.sort(root.children, &(&1.position < &2.position))
    assert root.children == children
  end
end
