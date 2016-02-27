defmodule GoalServer.StatusTest do
  use GoalServer.ModelCase

  alias GoalServer.Status

  @valid_attrs %{enable: true, name: "some content", position: 42, goal_id: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Status.changeset(%Status{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Status.changeset(%Status{}, @invalid_attrs)
    refute changeset.valid?
  end
end
