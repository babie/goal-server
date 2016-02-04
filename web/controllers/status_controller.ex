defmodule GoalServer.StatusController do
  use GoalServer.Web, :controller

  alias GoalServer.Status

  plug :scrub_params, "status" when action in [:create, :update]

  def index(conn, _params) do
    statuses = Repo.all(Status)
    render(conn, "index.json", statuses: statuses)
  end

  def create(conn, %{"status" => status_params}) do
    changeset = Status.changeset(%Status{}, status_params)

    case Repo.insert(changeset) do
      {:ok, status} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", status_path(conn, :show, status))
        |> render("show.json", status: status)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(GoalServer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    status = Repo.get!(Status, id)
    render(conn, "show.json", status: status)
  end

  def update(conn, %{"id" => id, "status" => status_params}) do
    status = Repo.get!(Status, id)
    changeset = Status.changeset(status, status_params)

    case Repo.update(changeset) do
      {:ok, status} ->
        render(conn, "show.json", status: status)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(GoalServer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    status = Repo.get!(Status, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(status)

    send_resp(conn, :no_content, "")
  end
end
