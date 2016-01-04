defmodule GoalServer.AuthenticationTest do
  use GoalServer.ModelCase

  alias GoalServer.User
  alias GoalServer.Authentication

  @valid_attrs %{oauth_token_secret: "some content", oauth_token: "some content", provider: "some content", uid: "some content", user_id: 1}
  @invalid_attrs %{}

  @secret System.get_env("OAUTH_TOKEN_CRYPT_SECRET")
  @salt System.get_env("OAUTH_TOKEN_CRYPT_SALT")

  setup do
    user = User.changeset(%User{}, %{nick: "user"})
    |> Repo.insert!
    auth = @valid_attrs
      |> Map.put(:user_id, user.id)
    auth = Authentication.upsert_changeset(%Authentication{}, auth)
    |> Repo.insert!
    {:ok, user: user, auth: auth}
  end

  test "changeset with valid attributes" do
    changeset = Authentication.upsert_changeset(%Authentication{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Authentication.upsert_changeset(%Authentication{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "oauth_token encryption", %{auth: auth} do
    assert auth.encrypted_oauth_token != nil
    assert auth.encrypted_oauth_token_secret != nil
  end

  test "encrypted_oauth_token decryption", %{auth: auth} do
    auth = (Repo.one! from a in Authentication, where: a.id == ^auth.id)
      |> Authentication.decrypt_token
    assert auth.oauth_token == Safetybox.decrypt(auth.encrypted_oauth_token, @secret, @salt)
    assert auth.oauth_token_secret == Safetybox.decrypt(auth.encrypted_oauth_token_secret, @secret, @salt)
  end
end
