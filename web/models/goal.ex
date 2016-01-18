defmodule GoalServer.Goal do
  use GoalServer.Web, :model

  schema "goals" do
    field :title, :string
    field :body, :string
    field :status, :string
    belongs_to :parent, __MODULE__
    field :position, :integer
    belongs_to :owner, GoalServer.User, foreign_key: :owned_by
    has_many :children, __MODULE__, foreign_key: :parent_id, on_delete: :delete_all

    timestamps
  end

  @required_fields ~w(title status position owned_by)
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

  def update_positions(changeset) do
    parent_id_changed = Map.has_key?(changeset.changes, :parent_id)
    old_parent_id = changeset.model.parent_id
    old_position = changeset.model.position
    new_parent_id = Map.get(changeset.changes, :parent_id) || Map.get(changeset.params, "parent_id")
    new_position = Map.get(changeset.changes, :position) || Map.get(changeset.params, "position")


    if old_parent_id && old_position do # not create
      if parent_id_changed do # move tree
        from(
          g in Goal,
          where:
            g.parent_id == ^new_parent_id and
            g.position >= ^new_position,
          update: [inc: [position: 1]]
        ) |> Repo.update_all([])
        from(
          g in Goal,
          where:
            g.parent_id == ^old_parent_id and
            g.position > ^old_position,
          update: [inc: [position: -1]]
        ) |> Repo.update_all([])
      else # move on children
        cond do
          # down
          old_position < new_position ->
            from(
              g in Goal,
              where:
                g.parent_id == ^old_parent_id and
                g.position > ^old_position and
                g.position < ^new_position,
              update: [inc: [position: -1]]
            ) |> Repo.update_all([])
            changes = Map.merge(changeset.changes, %{position: new_position - 1})
            changeset = Map.put(changeset, :changes, changes)

          # up
          old_position > new_position ->
            from(
              g in Goal,
              where:
                g.parent_id == ^old_parent_id and
                g.position < ^old_position and
                g.position >= ^new_position,
              update: [inc: [position: 1]]
            ) |> Repo.update_all([])
        end
      end
    else
      # insert
      from(
        g in Goal,
        where:
          g.parent_id == ^new_parent_id and
          g.position >= ^new_position,
        update: [inc: [position: 1]]
      ) |> Repo.update_all([])
    end

    changeset
  end

  def insert(changeset) do
    if changeset.valid? do
      Repo.transaction(fn ->
        changeset = update_positions(changeset)

        goal = changeset |> Repo.insert!

        goal
      end)
    else
      {:error, changeset}
    end
  end

  def update(changeset) do
    if changeset.valid? do
      Repo.transaction(fn ->
        changeset = update_positions(changeset)

        goal = changeset |> Repo.update!

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

