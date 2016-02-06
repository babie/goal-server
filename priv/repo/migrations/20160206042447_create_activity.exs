defmodule GoalServer.Repo.Migrations.CreateActivity do
  use Ecto.Migration

  def change do
    create table(:activities) do
      add :backup, :map
      add :diff, :map
      add :goal_id, references(:goals, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps
    end
    create index(:activities, [:goal_id])
    create index(:activities, [:user_id])

  end
end
