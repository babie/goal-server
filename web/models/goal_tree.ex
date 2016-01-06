defmodule GoalServer.GoalTree do
  use GoalServer.Web, :model

  schema "goal_trees" do
    field :generations, :integer
    field :position, :integer
    belongs_to :ancestor, GoalServer.Ancestor
    belongs_to :descendant, GoalServer.Descendant

    timestamps
  end

  @required_fields ~w(generations position)
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
