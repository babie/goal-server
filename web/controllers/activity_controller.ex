defmodule GoalServer.ActivityController do
  use GoalServer.Web, :controller

  alias GoalServer.Activity

  plug :scrub_params, "activity" when action in [:create, :update]

  def index(conn, _params) do
    activities = Repo.all(Activity)
    render(conn, "index.json", activities: activities)
  end

  def create(conn, %{"activity" => activity_params}) do
    changeset = Activity.changeset(%Activity{}, activity_params)

    case Repo.insert(changeset) do
      {:ok, activity} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", activity_path(conn, :show, activity))
        |> render("show.json", activity: activity)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(GoalServer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    activity = Repo.get!(Activity, id)
    render(conn, "show.json", activity: activity)
  end

  def update(conn, %{"id" => id, "activity" => activity_params}) do
    activity = Repo.get!(Activity, id)
    changeset = Activity.changeset(activity, activity_params)

    case Repo.update(changeset) do
      {:ok, activity} ->
        render(conn, "show.json", activity: activity)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(GoalServer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    activity = Repo.get!(Activity, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(activity)

    send_resp(conn, :no_content, "")
  end
end
