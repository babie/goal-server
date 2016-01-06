defmodule GoalServer.GoalTreeTest do
  use GoalServer.ModelCase

  alias GoalServer.GoalTree

  @valid_attrs %{generations: 42, position: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = GoalTree.changeset(%GoalTree{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = GoalTree.changeset(%GoalTree{}, @invalid_attrs)
    refute changeset.valid?
  end
end
