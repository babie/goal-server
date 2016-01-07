defmodule GoalServer.ProviderTest do
  use GoalServer.ModelCase

  alias GoalServer.User
  alias GoalServer.Provider

  @valid_attrs %{name: "some content", uid: "some content", access_token: "some content"}
  @invalid_attrs %{}

  setup do
    changeset = User.changeset(%User{}, %{nick: "test_user"})
    user = Repo.insert!(changeset)
    {:ok, user: user}
  end

  test "changeset with valid attributes", %{user: user} do
    attrs = Map.merge(@valid_attrs, %{user_id: user.id})
    changeset = Provider.changeset(%Provider{}, attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Provider.changeset(%Provider{}, @invalid_attrs)
    refute changeset.valid?
  end
end
