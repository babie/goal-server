defmodule GoalServer.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :nick, :string

      timestamps
    end
    create unique_index(:users, [:nick])

  end
end
