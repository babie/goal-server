defmodule GoalServer.MembershipController do
  use GoalServer.Web, :controller

  alias GoalServer.Membership

  plug :scrub_params, "membership" when action in [:create, :update]

  def index(conn, _params) do
    memberships = Repo.all(Membership)
    render(conn, "index.json", memberships: memberships)
  end

  def create(conn, %{"membership" => membership_params}) do
    changeset = Membership.changeset(%Membership{}, membership_params)

    case Repo.insert(changeset) do
      {:ok, membership} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", membership_path(conn, :show, membership))
        |> render("show.json", membership: membership)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(GoalServer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    membership = Repo.get!(Membership, id)
    render(conn, "show.json", membership: membership)
  end

  def update(conn, %{"id" => id, "membership" => membership_params}) do
    membership = Repo.get!(Membership, id)
    changeset = Membership.changeset(membership, membership_params)

    case Repo.update(changeset) do
      {:ok, membership} ->
        render(conn, "show.json", membership: membership)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(GoalServer.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    membership = Repo.get!(Membership, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(membership)

    send_resp(conn, :no_content, "")
  end
end
