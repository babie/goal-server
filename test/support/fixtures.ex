defmodule GoalServer.Fixtures do
  alias GoalServer.Repo
  alias GoalServer.User
  alias GoalServer.Goal
  alias GoalServer.GoalTree


  def fixture(:user) do
    Repo.insert! %User{nick: "test_user"}
  end

  def fixture(atom \\ nil, assoc \\ [])

  def fixture(:root, assoc) do
    user = assoc[:user] || fixture(:user)
    root = Repo.insert! %Goal{
      title: "root",
      status: "root",
      position: 0,
      owned_by: user.id,
      inserted_by: user.id,
      updated_by: user.id
    }

    Repo.insert! %GoalTree{
      ancestor_id: root.id,
      descendant_id: root.id,
      generations: 0
    }

    root
    |> Repo.preload(:goal_tree)
    |> Repo.preload(:owner)
  end

  def fixture(:children, assoc) do
    parent = assoc[:parent] || fixture(:root)
    Enum.reduce([0, 1, 2], [], fn(i, acc) -> 
      generations = Enum.filter_map(
        parent.goal_tree,
        fn(t) -> t.ancestor_id == t.descendant_id end,
        &(&1.generations)
      ) |> List.first

      child = Repo.insert! %Goal{
        title: "child#{generations}-#{i}",
        status: "todo",
        position: i,
        owned_by: parent.owner.id,
        inserted_by: parent.owner.id,
        updated_by: parent.owner.id
      }

      Repo.insert! %GoalTree{
        ancestor_id: child.id,
        descendant_id: child.id,
        generations: generations + 1
      }

      Repo.insert! %GoalTree{
        ancestor_id: parent.id,
        descendant_id: child.id,
        generations: generations + 1
      }

      child = child
      |> Repo.preload(:goal_tree)
      |> Repo.preload(:owner)

      acc ++ [child]
    end)
  end
end
