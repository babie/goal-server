defmodule GoalServer.Repo.Migrations.CreateGoalTree do
  use Ecto.Migration

  def change do
    create table(:goal_trees) do
      add :ancestor_id, references(:goals, on_delete: :nothing), null: false
      add :descendant_id, references(:goals, on_delete: :nothing), null: false
      add :generations, :integer, null: false
      add :position, :integer, null: false

      timestamps
    end
    create index(:goal_trees, [:ancestor_id])
    create index(:goal_trees, [:descendant_id])
    create index(:goal_trees, [:ancestor_id, :descendant_id, :generations], unique: true)

  end
end
