defmodule GoalServer.Provider do
  use GoalServer.Web, :model

  schema "providers" do
    field :name, :string
    field :uid, :string
    field :encrypted_access_token, :string
    field :encrypted_access_secret, :string
    field :access_token, :string, virtual: true
    field :access_secret, :string, virtual: true
    belongs_to :user, GoalServer.User

    timestamps
  end

  @required_fields ~w(name uid access_token user_id)
  @optional_fields ~w(access_secret)

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
