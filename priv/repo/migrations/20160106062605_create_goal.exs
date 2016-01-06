defmodule GoalServer.Repo.Migrations.CreateGoal do
  use Ecto.Migration

  def change do
    create table(:goals) do
      add :title, :string, null: false
      add :body, :text
      add :status, :string, null: false
      add :parent_id, references(:goals, on_delete: :nothing)
      add :owned_by, references(:users, on_delete: :nothing)
      add :inserted_by, references(:users, on_delete: :nothing)
      add :updated_by, references(:users, on_delete: :nothing)

      timestamps
    end
    create index(:goals, [:parent_id])
    create index(:goals, [:inserted_by])
    create index(:goals, [:updated_by])
    create index(:goals, [:owned_by])

  end
end
