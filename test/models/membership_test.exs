defmodule GoalServer.MembershipTest do
  use GoalServer.ModelCase

  alias GoalServer.Membership

  @valid_attrs %{status: "some content"}
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
