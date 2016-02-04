defmodule GoalServer.Repo.Migrations.CreateStatus do
  use Ecto.Migration

  def change do
    create table(:statuses) do
      add :name, :string
      add :position, :integer
      add :enable, :boolean, default: false
      add :project_id, references(:projects, on_delete: :nothing)

      timestamps
    end
    create index(:statuses, [:project_id])

  end
end
