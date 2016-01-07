defmodule GoalServer.GoalTest do
  use GoalServer.ModelCase

  alias GoalServer.User
  alias GoalServer.Goal

  @valid_attrs %{body: "some content", status: "some content", title: "some content"}
  @invalid_attrs %{}
  setup do
    user = Repo.insert! User.changeset(%User{}, %{nick: "some content"})
    {:ok, user: user}
  end

  test "changeset with valid attributes", %{user: user} do
    changeset = Goal.changeset(%Goal{}, Map.merge(@valid_attrs, %{owned_by: user.id, inserted_by: user.id, updated_by: user.id}))
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Goal.changeset(%Goal{}, @invalid_attrs)
    refute changeset.valid?
  end
end
