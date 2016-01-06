defmodule GoalServer.GoalTest do
  use GoalServer.ModelCase

  alias GoalServer.Goal

  @valid_attrs %{body: "some content", status: "some content", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Goal.changeset(%Goal{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Goal.changeset(%Goal{}, @invalid_attrs)
    refute changeset.valid?
  end
end
