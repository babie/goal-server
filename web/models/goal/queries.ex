defmodule GoalServer.Goal.Queries do
  import Ecto.Query, only: [from: 1, from: 2]

  alias Ecto.Adapters.SQL
  alias GoalServer.Repo
  alias GoalServer.Goal
  use GoalServer.Model.Utils

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

  def descendant_ids(goal) do
    [_first|rest] = self_and_descendant_ids(goal)
    rest
  end

  def self_and_descendant_ids(goal) do
    self_and_descendants_sql(goal)
    |> load([:id])
    |> Enum.map(fn(kw) -> Keyword.get(kw, :id) end)
  end

  def descendants(goal) do
    [_first|rest] = self_and_descendants(goal)
    rest
  end

  def self_and_descendants(goal) do
    self_and_descendants_sql(goal) |> load_into(Goal)
  end

  def self_and_descendants_sql(goal) do
    SQL.query!(
      Repo,
      """
      WITH RECURSIVE
        goal_tree (
          id,
          title,
          body,
          status,
          parent_id,
          position,
          owned_by,
          inserted_at,
          updated_at,
          depth
        )
      AS (
          SELECT
            *, 0
          FROM
            goals
          WHERE
            id = $1::integer
        UNION ALL
          SELECT
            g.*, t.depth + 1
          FROM
            goal_tree AS t
            JOIN
              goals AS g
            ON
              t.id = g.parent_id
      )
      SELECT
        t.*
      FROM
        goal_tree AS t
      ORDER BY
        t.depth, t.position
      ;
      """,
      [goal.id]
    )
  end

end
