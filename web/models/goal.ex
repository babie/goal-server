defmodule GoalServer.Goal do
  use GoalServer.Web, :model

  schema "goals" do
    field :title, :string
    field :body, :string
    field :status, :string
    field :position, :integer
    has_many :children, __MODULE__, foreign_key: :parent_id, on_delete: :delete_all
    belongs_to :parent, __MODULE__
    belongs_to :owner, GoalServer.User, foreign_key: :owned_by
    belongs_to :creator, GoalServer.User, foreign_key: :inserted_by
    belongs_to :updater, GoalServer.User, foreign_key: :updated_by

    timestamps
  end

  @required_fields ~w(title status position owned_by inserted_by updated_by)
  @optional_fields ~w(body parent_id)

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> foreign_key_constraint(:parent_id)
  end

end

defmodule GoalServer.Goal.Commands do
  import Ecto.Query, only: [from: 1, from: 2]

  alias GoalServer.Repo
  alias GoalServer.Goal

  def update_positions(parent_id, position) do
    from(
      g in Goal,
      where:
        g.parent_id == ^parent_id and
        g.position >= ^position,
      update: [inc: [position: 1]]
    ) |> Repo.update_all([])
  end

  def insert(changeset) do
    if changeset.valid? do
      Repo.transaction(fn ->
        parent_id = Map.get(changeset.params, "parent_id")
        position = Map.get(changeset.params, "position")
        if parent_id do
          update_positions(parent_id, position)
        end

        goal = changeset |> Repo.insert!

        goal
      end)
    else
      {:error, changeset}
    end
  end

  def siblings(goal) do
    from(
      g in Goal,
      where:
        g.parent_id == ^goal.parent_id and
        g.id != ^goal.id,
      order_by: g.position,
      select: g
    ) |> Repo.all
  end
end

