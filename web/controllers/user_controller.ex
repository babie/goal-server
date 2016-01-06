defmodule GoalServer.UserController do
  use GoalServer.Web, :controller

  alias GoalServer.User
  alias GoalServer.Authentication
  alias GoalServer.Goal

  plug :scrub_params, "user" when action in [:create, :update]

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = User.changeset(%User{}, get_session(conn, :tmp_user))
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)
    ret = if changeset.valid? do
      Repo.transaction(fn ->
        user = Repo.insert!(changeset)
        auth = get_session(conn, :tmp_user).auth
          |> Map.put(:user_id, user.id)
        Authentication.upsert_changeset(%Authentication{}, auth)
        |> Repo.insert!
        user
        goal = Goal.changeset(
          %Goal{}, %{
            title: "root",
            status: "todo",
            owned_by: user.id,
            inserted_by: user.id,
            updated_by: user.id
          }
        )
        |> Repo.insert!
      end)
    else
      {:error, changeset}
    end

    case ret do
      {:ok, user} ->
        conn
        |> delete_session(:tmp_user)
        |> put_session(:current_user, user)
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: user_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Repo.get!(User, id)
    changeset = User.changeset(user, user_params)

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))
      {:error, changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Repo.get!(User, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: user_path(conn, :index))
  end
end
