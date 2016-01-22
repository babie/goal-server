defmodule GoalServer.Goal.Queries do
  import Ecto.Query, only: [from: 1, from: 2]

  alias GoalServer.Repo
  alias GoalServer.Goal

  def root?(goal) do
    goal.parent_id == nil
  end

  def siblings(goal) do
    from(
      g in Goal,
      where:
        g.parent_id == ^goal.parent_id and
        g.id != ^goal.id,
      order_by: g.position,
      select: g
    ) |> Repo.all
  end

end
