defmodule GoalServer.Fixtures do
  alias GoalServer.Repo
  alias GoalServer.User
  alias GoalServer.Goal
  alias GoalServer.Membership


  def fixture(:user) do
    Repo.insert! %User{nick: "test_user"}
  end

  def fixture(atom \\ nil, assoc \\ [])

  def fixture(:membership, assoc) do
    user = assoc[:user] || fixture(:user)
    goal = assoc[:goal] || fixture(:goal)
    Repo.insert! %Membership{
      goal_id: goal.id,
      user_id: user.id,
      status: "authorized"
    }
  end

  def fixture(:root, assoc) do
    Repo.insert! %Goal{
      title: "goal",
      status_id: 0,
      position: 0,
    }
  end

  def fixture(:children, assoc) do
    parent = (assoc[:parent] || fixture(:root))
    Enum.reduce([0, 1, 2], [], fn(i, acc) -> 

      child = Repo.insert! %Goal{
        title: "#{parent.title}-#{i}",
        status_id: 0,
        parent_id: parent.id,
        position: i,
      }

      acc ++ [child]
    end)
  end
end
