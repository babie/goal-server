defmodule GoalServer.GoalTreeTest do
  use GoalServer.ModelCase

  alias GoalServer.GoalTree

  @valid_attrs %{ancestor_id: 42, descendant_id: 42, generations: 42}
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
