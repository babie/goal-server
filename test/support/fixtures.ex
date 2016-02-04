defmodule GoalServer.Fixtures do
  alias GoalServer.Repo
  alias GoalServer.User
  alias GoalServer.Project
  alias GoalServer.Membership
  alias GoalServer.Goal


  def fixture(:user) do
    Repo.insert! %User{nick: "test_user"}
  end

  def fixture(:project) do
    Repo.insert! %Project{name: "test_user"}
  end

  def fixture(atom \\ nil, assoc \\ [])

  def fixture(:membership, assoc) do
    user = assoc[:user] || fixture(:user)
    project = assoc[:project] || fixture(:project)
    Repo.insert! %Membership{
      project_id: project.id,
      user_id: user.id,
      status: "authorized"
    }
  end

  def fixture(:root, assoc) do
    project = assoc[:project] || fixture(:project)
    Repo.insert! %Goal{
      title: "goal",
      status: "root",
      position: 0,
      project_id: project.id,
    }
  end

  def fixture(:children, assoc) do
    parent = (assoc[:parent] || fixture(:root))
    |> Repo.preload(:project)
    Enum.reduce([0, 1, 2], [], fn(i, acc) -> 

      child = Repo.insert! %Goal{
        title: "#{parent.title}-#{i}",
        status: "todo",
        parent_id: parent.id,
        position: i,
        project_id: parent.project_id,
      }

      acc ++ [child]
    end)
  end
end
