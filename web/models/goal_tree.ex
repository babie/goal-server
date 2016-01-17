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

  def update(goal) do
    # delete old ancestors and there's descendants
    SQL.query!(
      Repo,
      """
      DELETE FROM
        goal_trees AS t
      WHERE
        t.descendant_id IN (
          SELECT
            x.id
          FROM (
            SELECT
              descendant_id AD id
            FROM
              goal_trees
            WHERE
              ancestor_id = ?
          ) AS x 
        )
        AND
        t.ancestor_id IN (
          SELECT
            y.id
          FROM
            goal_trees
          WHERE
            descendant_id = ?
            AND
            ancestor_id != descendant_id
          ) AS y
        )
      ;
      """,
      [goal.id, goal.id]
    )
    # insert new ancestors and there's descendants
    # TODO: generations
    SQL.query!(
      Repo,
      """
      INSERT INTO
        goal_trees(ancestor_id, descendant_id, generations)
      (
        SELECT
          supertree.ancestor_id,
          subtree.descendant_id,
          subtree.generations
        FROM
          goal_trees AS supertree
          CROSS JOIN
          goal_trees AS subtree
        WHERE
          supertree.descendant_id = ?
          AND
          subtree.ancestor_id = ?
      )
      ;
      """,
      [goal.parent_id, goal.id]
    )
  end
end
