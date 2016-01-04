defmodule GoalServer.Repo.Migrations.CreateAuthentication do
  use Ecto.Migration

  def change do
    create table(:authentications) do
      add :provider, :string
      add :uid, :string
      add :encrypted_oauth_token, :string
      add :encrypted_oauth_token_secret, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps
    end
    create index(:authentications, [:user_id])

  end
end
