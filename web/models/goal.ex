defmodule GoalServer.Goal do
  use GoalServer.Web, :model

  schema "goals" do
    field :title, :string
    field :body, :string
    field :status, :string
    belongs_to :parent, __MODULE__
    field :position, :integer
    belongs_to :project, GoalServer.Project
    has_many :children, __MODULE__, foreign_key: :parent_id, on_delete: :delete_all

    timestamps
  end

  @required_fields ~w(title status position project_id)
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
