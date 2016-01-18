defmodule GoalServer.Fixtures do
  alias GoalServer.Repo
  alias GoalServer.User
  alias GoalServer.Goal


  def fixture(:user) do
    Repo.insert! %User{nick: "test_user"}
  end

  def fixture(atom \\ nil, assoc \\ [])

  def fixture(:root, assoc) do
    user = assoc[:user] || fixture(:user)
    Repo.insert! %Goal{
      title: "root",
      status: "root",
      position: 0,
      owned_by: user.id,
    }
  end

  def fixture(:children, assoc) do
    parent = (assoc[:parent] || fixture(:root))
    |> Repo.preload(:owner)
    Enum.reduce([0, 1, 2], [], fn(i, acc) -> 

      child = Repo.insert! %Goal{
        title: "child-#{i}",
        status: "todo",
        parent_id: parent.id,
        position: i,
        owned_by: parent.owner.id,
      }

      acc ++ [child]
    end)
  end
end
