defmodule GoalServer.Authentication do
  use GoalServer.Web, :model

  schema "authentications" do
    field :provider, :string
    field :uid, :string
    field :encrypted_oauth_token, :string
    field :encrypted_oauth_token_secret, :string
    field :oauth_token, :string, virtual: true
    field :oauth_token_secret, :string, virtual: true
    belongs_to :user, GoalServer.User

    timestamps
  end

  @required_fields ~w(provider uid oauth_token oauth_token_secret user_id)
  @optional_fields ~w()

  @secret System.get_env("OAUTH_TOKEN_CRYPT_SECRET")
  @salt System.get_env("OAUTH_TOKEN_CRYPT_SALT")

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end

  def upsert_changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> encrypt_token
  end

  def decrypt_token(auth) do
    encrypted_oauth_token = auth.encrypted_oauth_token
    encrypted_oauth_token_secret = auth.encrypted_oauth_token_secret

    auth
    |> Map.put(:oauth_token, Safetybox.decrypt(encrypted_oauth_token, @secret, @salt))
    |> Map.put(:oauth_token_secret, Safetybox.decrypt(encrypted_oauth_token_secret, @secret, @salt))
  end

  def encrypt_token(changeset) do
    oauth_token = get_field(changeset, :oauth_token)
    oauth_token_secret = get_field(changeset, :oauth_token_secret)

    changeset
    |> change(encrypted_oauth_token: Safetybox.encrypt(oauth_token, @secret, @salt))
    |> change(encrypted_oauth_token_secret: Safetybox.encrypt(oauth_token_secret, @secret, @salt))
  end
end
