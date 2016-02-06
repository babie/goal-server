defmodule GoalServer.Activity do
  use GoalServer.Web, :model

  schema "activities" do
    field :backup, :map
    field :diff, :map
    belongs_to :goal, GoalServer.Goal
    belongs_to :user, GoalServer.User

    timestamps
  end

  @required_fields ~w(backup diff)
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
