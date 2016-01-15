defmodule GoalServer.Goal do
  use GoalServer.Web, :model

  schema "goals" do
    field :title, :string
    field :body, :string
    field :status, :string
    field :position, :integer
    field :parent_id, :integer, virtual: true
    field :generations, :integer, virtual: true
    has_many :descendant_tree, GoalServer.GoalTree, foreign_key: :ancestor_id, on_delete: :delete_all
    has_many :descendants, through: [:descendant_tree, :descendant], on_delete: :delete_all
    belongs_to :owner, GoalServer.User, foreign_key: :owned_by
    belongs_to :creator, GoalServer.User, foreign_key: :inserted_by
    belongs_to :updater, GoalServer.User, foreign_key: :updated_by

    timestamps
  end

  @required_fields ~w(title status position generations owned_by inserted_by updated_by)
  @optional_fields ~w(body parent_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

end

defmodule GoalServer.Goal.Commands do
  alias GoalServer.Repo
  import Ecto.Query, only: [from: 1, from: 2]
  alias Ecto.Adapters.SQL
  alias GoalServer.Goal
  alias GoalServer.GoalTree

  def insert(changeset) do
    if changeset.valid? do
      # Update position
      Repo.transaction(fn ->
        parent_id = Map.get(changeset.params, "parent_id")
        position = Map.get(changeset.params, "position")
        from(
          g in Goal,
          join: t in GoalTree, on: g.id == t.descendant_id,
          where:
            t.ancestor_id == ^parent_id and
            t.descendant_id != ^parent_id and
            g.position >= ^position,
          update: [inc: ["position": 1]]
        ) |> Repo.update_all([])

        # insert goal
        goal = changeset |> Repo.insert!

        # insert self path
        %GoalTree{
          ancestor_id: goal.id,
          descendant_id: goal.id,
          generations: goal.generations
        } |> Repo.insert!

        # insert path as child
        %GoalTree{
          ancestor_id: goal.parent_id,
          descendant_id: goal.id,
          generations: goal.generations
        } |> Repo.insert!

        goal
      end)
    else
      {:error, changeset}
    end
  end

  def self_and_children_query(goal) do
    from(
      g in Goal,
      select: g,
      inner_join: t in GoalTree, on: g.id == t.descendant_id,
      where: t.ancestor_id == ^goal.id,
      order_by: g.position
    )
  end

  def children_query(goal) do
    query = self_and_children_query(goal)
    from(
      [g, t] in query,
      where: t.descendant_id != ^goal.id
    )
  end

  def children(goal) do
    children_query(goal) |> Repo.all
  end

  def self_and_parent_query(goal) do
    from(
      g in Goal,
      select: g,
      inner_join: t in GoalTree, on: g.id == t.ancestor_id,
      where: t.descendant_id == ^goal.id,
      order_by: [desc: t.generations]
    )
  end

  def parent_query(goal) do
    query = self_and_parent_query(goal)
    from(
      [g, t] in query,
      where: t.ancestor_id != ^goal.id
    )
  end

  def parent(goal) do
    parent_query(goal) |> Repo.one
  end

  def siblings(goal) do
    SQL.query!(
      Repo,
      """
      SELECT
        g.*
      FROM
        goals AS g
      WHERE
        g.id IN (
          SELECT
            t1.descendant_id
          FROM
            goal_trees AS t1
          WHERE
            t1.ancestor_id IN (
              SELECT
                t2.ancestor_id
              FROM
                goal_trees AS t2
              WHERE
                t2.descendant_id = ?
                AND
                t2.ancestor_id <> t2.descendant_id
          )
          AND
          t1.ancestor_id <> t1.descendant_id
        )
        AND
        g.id <> ?
      ORDER BY
        g.position ASC
      ;
      """,
      [goal.id, goal.id]
    ) |> load_into(Goal)
  end

  defp load_into(response, model) do
    Enum.map response.rows, fn(row) ->
      fields = Enum.reduce(
        Enum.zip(response.columns, row),
        %{},
        fn({key, value}, map) -> Map.put(map, key, value) end
      )

      Ecto.Schema.__load__(
        model, nil, nil, [], fields, &Repo.__adapter__.load/2
      )
    end
  end
end
