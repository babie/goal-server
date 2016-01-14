defmodule GoalServer.Goal do
  use GoalServer.Web, :model

  schema "goals" do
    field :title, :string
    field :body, :string
    field :status, :string
    field :position, :integer
    has_many :goal_tree, GoalServer.GoalTree, foreign_key: :ancestor_id
    belongs_to :parent, GoalServer.Goal
    belongs_to :owner, GoalServer.User, foreign_key: :owned_by
    belongs_to :creator, GoalServer.User, foreign_key: :inserted_by
    belongs_to :updater, GoalServer.User, foreign_key: :updated_by

    timestamps
  end

  @required_fields ~w(title status owned_by inserted_by updated_by)
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

end

defmodule GoalServer.Goal.Queries do
  alias GoalServer.Repo
  import Ecto.Query, only: [from: 1, from: 2]
  alias GoalServer.Goal
  alias GoalServer.GoalTree

  def self_and_children(goal_id) do
    from(
      g in Goal,
      select: g,
      inner_join: t in GoalTree, on: g.id == t.descendant_id,
      where: t.ancestor_id == ^goal_id,
      order_by: g.position
    )
  end

  def children(goal_id) do
    query = self_and_children(goal_id)
    from(
      [g, t] in query,
      where: t.descendant_id != ^goal_id
    )
  end

  def self_and_ancestor(goal_id) do
    from(
      g in Goal,
      select: g,
      inner_join: t in GoalTree, on: g.id == t.ancestor_id,
      where: t.descendant_id == ^goal_id,
      order_by: [desc: t.generations]
    )
  end

  def ancestor(goal_id) do
    query = self_and_ancestor(goal_id)
    from(
      [g, t] in query,
      where: t.ancestor_id != ^goal_id
    )
  end
end
