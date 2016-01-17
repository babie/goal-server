defmodule GoalServer.GoalTree do
  use GoalServer.Web, :model

  alias Ecto.Adapters.SQL
  alias GoalServer.Repo

  schema "goal_trees" do
    field :generations, :integer
    belongs_to :ancestor, GoalServer.Goal
    belongs_to :descendant, GoalServer.Goal
  end

  @required_fields ~w(ancestor_id descendant_id generations)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def insert(goal) do
    SQL.query!(
      Repo,
      """
      INSERT INTO
        goal_trees(ancestor_id, descendant_id, generations)
          SELECT
            t.ancestor_id, ?, t.generations + 1
          FROM
            goal_trees AS t
          WHERE
            t.descendant_id = ?
        UNION ALL
          SELECT
            ?, ?, 0
      ;
      """,
      [goal.id, goal.parent_id, goal.id, goal.id]
    )
  end
end
