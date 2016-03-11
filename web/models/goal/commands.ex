defmodule GoalServer.Goal.Commands do
  import Ecto.Query, only: [from: 1, from: 2]

  alias Ecto.Adapters.SQL
  alias GoalServer.Repo
  alias GoalServer.Goal
  use GoalServer.Model.Utils

  def update_positions_on_move_up(parent_id, old_position, new_position) do
    from(
      g in Goal,
      where:
        g.parent_id == ^parent_id and
        g.position < ^old_position and
        g.position >= ^new_position,
      update: [inc: [position: 1]]
    ) |> Repo.update_all([])
  end

  def update_positions_on_move_down(parent_id, old_position, new_position) do
    from(
      g in Goal,
      where:
        g.parent_id == ^parent_id and
        g.position > ^old_position and
        g.position < ^new_position,
      update: [inc: [position: -1]]
    ) |> Repo.update_all([])
  end

  def update_positions_on_move_subtree(old_parent_id, old_position, new_parent_id, new_position) do
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
  end

  def update_positions_on_insert(new_parent_id, new_position) do
    from(
      g in Goal,
      where:
        g.parent_id == ^new_parent_id and
        g.position >= ^new_position,
      update: [inc: [position: 1]]
    ) |> Repo.update_all([])
  end

  def update_positions_on_delete(delete_parent_id, delete_position) do
    from(
      g in Goal,
      where:
        g.parent_id == ^delete_parent_id and
        g.position > ^delete_position,
      update: [inc: [position: -1]]
    ) |> Repo.update_all([])
  end

  def update_positions(changeset) do
    parent_id_changed = Map.has_key?(changeset.changes, :parent_id)
    old_parent_id = changeset.model.parent_id
    old_position = changeset.model.position
    new_parent_id = Map.get(changeset.changes, :parent_id) || Map.get(changeset.params, "parent_id")
    new_position = Map.get(changeset.changes, :position) || Map.get(changeset.params, "position")


    if old_parent_id && old_position do # not create
      if parent_id_changed do # move subtree
        update_positions_on_move_subtree(old_parent_id, old_position, new_parent_id, new_position)
      else # move between children
        cond do
          # down
          old_position < new_position ->
            update_positions_on_move_down(old_parent_id, old_position, new_position)
            changes = Map.merge(changeset.changes, %{position: new_position - 1})
            changeset = Map.put(changeset, :changes, changes)
          # up
          old_position > new_position ->
            update_positions_on_move_up(old_parent_id, old_position, new_position)
          old_position == new_position ->
            changeset # noghing to do
        end
      end
    else
      # insert
      update_positions_on_insert(new_parent_id, new_position)
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
    if changeset.valid? && !Goal.Queries.root?(changeset.model) do
      Repo.transaction(fn ->
        block_move_descendant_to_ancestor(changeset)

        changeset = update_positions(changeset)

        goal = changeset |> Repo.update!

        goal
      end)
    else
      if Goal.Queries.root?(changeset.model) do
        changeset = Ecto.Changeset.add_error(changeset, :parent_id, "can't be empty")
      end
      {:error, changeset}
    end
  end
  
  def delete(goal) do
    unless Goal.Queries.root?(goal) do
      Repo.transaction(fn ->
        update_positions_on_delete(goal.parent_id, goal.position)
        Repo.delete!(goal)
      end)
    end
  end

  def block_move_descendant_to_ancestor(changeset) do
    new_parent_id = Map.get(changeset.changes, :parent_id)
    if new_parent_id do
      d_ids = Goal.Queries.descendant_ids(changeset.model)
      if Enum.any?(d_ids, fn(d_id) -> d_id == new_parent_id end) do
        raise ArgumentError, message: "TODO: can't move to self descedants"
      end
    end
  end

  def copy(goal, parent_id, position) do
    Repo.transaction(fn ->
      update_positions_on_insert(parent_id, position)

      sql = """
        INSERT INTO
          goals (
            id,
            title,
            body,
            status_id,
            parent_id,
            position,
            inserted_at,
            updated_at
          )
        SELECT
          new_id,
          title,
          body,
          status_id,
          COALESCE(new_parent_id, $1::integer),
          new_position,
          inserted_at,
          updated_at
        FROM (
          WITH RECURSIVE subtrees AS (
            SELECT
              *,
              nextval('goals_id_seq') AS new_id,
              $2::integer AS new_position
            FROM
              goals
            WHERE
              id = $3::integer
            UNION ALL
            SELECT
              goals.*,
              nextval('goals_id_seq') AS new_id,
              goals.position AS new_position
            FROM
              subtrees
              JOIN goals ON subtrees.id = goals.parent_id
          )
          SELECT
            s1.new_id,
            s1.title,
            s1.body,
            s1.status_id,
            s2.new_id AS new_parent_id,
            s1.new_position AS new_position,
            s1.inserted_at,
            s1.updated_at
          FROM
            subtrees s1
            LEFT JOIN
              subtrees s2
            ON
              s1.parent_id = s2.id
        ) AS q1
        RETURNING
          *
        ;
      """ |> String.replace(~r/\n +/, " ")

      SQL.query!(
        Repo,
        sql,
        [parent_id, position, goal.id]
      ) |> load_into(Goal)
    end)
  end
end

