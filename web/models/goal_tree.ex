defmodule GoalServer.GoalTree do
  use GoalServer.Web, :model

  schema "goal_trees" do
    field :generations, :integer
    belongs_to :ancestor, GoalServer.Goal
    belongs_to :descendant, GoalServer.Goal

    timestamps
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
end
