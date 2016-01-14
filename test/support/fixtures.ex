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
    Repo.insert! %Goal{
      title: "root",
      status: "root",
      owned_by: user.id,
      inserted_by: user.id,
      updated_by: user.id
    }
    |> Repo.preload(:owner)
  end

  def fixture(:children, assoc) do
    root = assoc[:root] || fixture(:root)
    Enum.reduce([1,2,3], [], fn(i, acc) -> 
      child = Repo.insert! %Goal{
        title: "child#{i}",
        status: "todo",
        position: i - 1,
        parent_id: root.id,
        owned_by: root.owner.id,
        inserted_by: root.owner.id,
        updated_by: root.owner.id
      }
      Repo.insert! %GoalTree{
        ancestor_id: root.id,
        descendant_id: child.id,
        generations: 0
      }
      acc ++ [child]
    end)
  end
end
