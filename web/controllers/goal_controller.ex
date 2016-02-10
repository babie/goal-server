defmodule GoalServer.GoalController do
  use GoalServer.Web, :controller

  alias GoalServer.Goal

  plug :scrub_params, "goal" when action in [:create, :update]

  def index_html(conn, _params) do
    user = get_session(conn, :current_user) |> Repo.preload(:roots)
    roots = user.roots |> Enum.sort(&(&1.position < &2.position))
    goals = roots |> Enum.flat_map(fn(r) -> Goal.Queries.self_and_descendants(r) end)
    render(conn, "index.html", goals: goals)
  end

  def index(conn, _params) do
    user = get_session(conn, :current_user) |> Repo.preload(:roots)
    roots = user.roots |> Enum.sort(&(&1.position < &2.position))
    goals = roots |> Enum.flat_map(fn(r) -> Goal.Queries.self_and_descendants(r) end)
    render(conn, "index.json", goals: goals)
  end

  def create(conn, %{"goal" => goal_params}) do
    changeset = Goal.changeset(%Goal{}, goal_params)

    case Goal.Commands.insert(changeset) do
      {:ok, goal} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", goal_path(conn, :show, goal))
        |> render("show.json", goal: goal)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(GoalServer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show_html(conn, %{"id" => id}) do
    goal = Repo.get!(Goal, id)
    render(conn, "show.html", goal: goal)
  end

  def show(conn, %{"id" => id}) do
    goal = Repo.get!(Goal, id)
    render(conn, "show.json", goal: goal)
  end

  def update(conn, %{"id" => id, "goal" => goal_params}) do
    goal = Repo.get!(Goal, id)
    changeset = Goal.changeset(goal, goal_params)

    case Goal.Commands.update(changeset) do
      {:ok, goal} ->
        render(conn, "show.json", goal: goal)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(GoalServer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    goal = Repo.get!(Goal, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(goal)

    send_resp(conn, :no_content, "")
  end

  def copy(conn, %{"target_id" => target_id, "dest_parent_id" => dest_parent_id, "dest_position" => dest_position}) do
    target_goal = Repo.get!(Goal, target_id)
    dest_parent = Repo.get!(Goal, dest_parent_id)
    dest_goal = Repo.get_by(Goal, parent_id: dest_parent_id, position: dest_position)
    if dest_parent && dest_goal == nil do
      dest_positiong = "0"
    end

     case Goal.Commands.copy(target_goal, String.to_integer(dest_parent_id), String.to_integer(dest_position)) do
      {:ok, goals} ->
        conn
        |> put_status(:created)
        |> render("index.json", goals: goals)
      {:error, exception} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(GoalServer.GoalView, "error.json", exception: exception)
    end
  end

  def roots(conn, _params) do
    user = get_session(conn, :current_user) |> Repo.preload(:roots)
    roots = user.roots |> Enum.sort(&(&1.position < &2.position))
    render(conn, "index.json", goals: roots)
  end

  def children(conn, %{"id" => id}) do
    goal = Goal |> Repo.get!(id) |> Repo.preload(:children)
    # TODO: user check
    children = goal.children |> Enum.sort(&(&1.position < &2.position))
    render(conn, "index.json", goals: children)
  end
  
  def parent(conn, %{"id" => id}) do
    goal = Goal |> Repo.get!(id) |> Repo.preload(:parent) 
    # TODO: user check
    parent = goal.parent
    render(conn, "show.json", goal: parent)
  end

  def siblings(conn, %{"id" => id}) do
    goal = Goal |> Repo.get!(id)
    # TODO: user check
    siblings = goal |> Goal.Queries.siblings
    render(conn, "index.json", goals: siblings)
  end
end
