defmodule GoalServer.Repo.Migrations.CreateStatus do
  use Ecto.Migration

  def change do
    create table(:statuses) do
      add :name, :string
      add :position, :integer
      add :enable, :boolean, default: false
      add :goal_id, references(:goals, on_delete: :nothing)

      timestamps
    end
    create index(:statuses, [:goal_id])

  end
end
