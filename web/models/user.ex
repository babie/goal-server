defmodule GoalServer.User do
  use GoalServer.Web, :model

  schema "users" do
    field :nick, :string
    has_many :providers, GoalServer.Provider, on_delete: :delete_all
    has_many :memberships, GoalServer.Membership
    has_many :projects, through: [:memberships, :project]

    timestamps
  end

  @required_fields ~w(nick)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:nick)
  end
end
