defmodule GoalServer.MembershipTest do
  use GoalServer.ModelCase

  alias GoalServer.Membership

  @valid_attrs %{goal_id: 42, user_id: 42, status: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Membership.changeset(%Membership{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Membership.changeset(%Membership{}, @invalid_attrs)
    refute changeset.valid?
  end
end
