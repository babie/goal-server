defmodule GoalServer.ActivityTest do
  use GoalServer.ModelCase

  alias GoalServer.Activity

  @valid_attrs %{backup: %{}, diff: %{}}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Activity.changeset(%Activity{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Activity.changeset(%Activity{}, @invalid_attrs)
    refute changeset.valid?
  end
end
