defmodule GoalServer.GoalController do
  use GoalServer.Web, :controller

  alias GoalServer.Goal

  plug :scrub_params, "goal" when action in [:create, :update]

  def index(conn, _params) do
    goals = Repo.all(Goal)
    render(conn, "index.json", goals: goals)
  end

  def create(conn, %{"goal" => goal_params}) do
    changeset = Goal.changeset(%Goal{}, goal_params)

    case Repo.insert(changeset) do
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

    case Repo.update(changeset) do
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

  def children(conn, %{"id" => id}) do
    goal = Goal |> Repo.get!(id)
    # TODO: user check
    children = goal |> Goal.Commands.children
    render(conn, "index.json", goals: children)
  end
  
  def parent(conn, %{"id" => id}) do
    goal = Goal |> Repo.get!(id)
    parent = goal |> Goal.Commands.parent
    render(conn, "show.json", goal: parent)
  end
end
