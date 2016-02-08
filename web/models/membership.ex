defmodule GoalServer.Membership do
  use GoalServer.Web, :model

  schema "memberships" do
    field :status, :string
    belongs_to :user, GoalServer.User
    belongs_to :goal, GoalServer.Goal

    timestamps
  end

  @required_fields ~w(goal_id user_id status)
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
