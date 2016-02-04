defmodule GoalServer.Status do
  use GoalServer.Web, :model

  schema "statuses" do
    field :name, :string
    field :position, :integer
    field :enable, :boolean, default: false
    belongs_to :project, GoalServer.Project

    timestamps
  end

  @required_fields ~w(name position enable)
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
