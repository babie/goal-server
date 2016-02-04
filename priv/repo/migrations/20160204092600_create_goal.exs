defmodule GoalServer.Repo.Migrations.CreateGoal do
  use Ecto.Migration

  def change do
    create table(:goals) do
      add :title, :string, null: false
      add :body, :text
      add :status, :string, null: false
      add :parent_id, references(:goals, on_delete: :delete_all)
      add :position, :integer
      add :project_id, references(:projects, on_delete: :nothing)

      timestamps
    end
    create index(:goals, [:parent_id])
    create index(:goals, [:project_id])

  end
end
