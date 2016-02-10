defmodule GoalServer.Goal do
  use GoalServer.Web, :model

  schema "goals" do
    field :title, :string
    field :body, :string
    field :status, :string
    belongs_to :parent, __MODULE__
    field :position, :integer
    has_many :children, __MODULE__, foreign_key: :parent_id, on_delete: :delete_all
    has_many :memberships, GoalServer.Membership
    has_many :users, through: [:memberships, :user]

    timestamps
  end

  @required_fields ~w(title status position)
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
