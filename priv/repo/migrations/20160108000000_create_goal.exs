defmodule GoalServer.Repo.Migrations.CreateGoal do
  use Ecto.Migration

  def change do
    create table(:goals) do
      add :title, :string, null: false
      add :body, :text
      add :status_id, :integer, null: false
      add :parent_id, references(:goals, on_delete: :delete_all)
      add :position, :integer

      timestamps
    end
    create index(:goals, [:parent_id])

  end
end
