defmodule GoalServer.Goal.Queries do
  import Ecto.Query, only: [from: 1, from: 2]

  def root?(goal) do
    goal.parent_id == nil
  end
end
