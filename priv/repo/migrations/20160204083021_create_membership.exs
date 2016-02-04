defmodule GoalServer.Repo.Migrations.CreateMembership do
  use Ecto.Migration

  def change do
    create table(:memberships) do
      add :status, :string
      add :user_id, references(:users, on_delete: :nothing)
      add :project_id, references(:projects, on_delete: :nothing)

      timestamps
    end
    create index(:memberships, [:user_id])
    create index(:memberships, [:project_id])

  end
end
