defmodule GoalServer.Goal do
  use GoalServer.Web, :model

  schema "goals" do
    field :title, :string
    field :body, :string
    field :status, :string
    belongs_to :parent, GoalServer.Parent
    belongs_to :inserted_by, GoalServer.InsertedBy
    belongs_to :updated_by, GoalServer.UpdatedBy
    belongs_to :owned_by, GoalServer.OwnedBy

    timestamps
  end

  @required_fields ~w(title body status)
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
