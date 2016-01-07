defmodule GoalServer.Repo.Migrations.CreateProvider do
  use Ecto.Migration

  def change do
    create table(:providers) do
      add :name, :string
      add :uid, :string
      add :encrypted_access_token, :string
      add :encrypted_access_secret, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps
    end
    create index(:providers, [:user_id])

  end
end
