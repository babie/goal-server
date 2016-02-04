defmodule GoalServer.Project do
  use GoalServer.Web, :model

  schema "projects" do
    field :name, :string
    has_many :memberships, GoalServer.Membership
    has_many :members, through: [:memberships, :user]
    has_many :goals, GoalServer.Goal, foreign_key: :project_id, on_delete: :delete_all

    timestamps
  end

  @required_fields ~w(name)
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
