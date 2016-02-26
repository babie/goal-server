defmodule GoalServer.UserController do
  use GoalServer.Web, :controller

  alias GoalServer.User
  alias GoalServer.Membership
  alias GoalServer.Goal
  alias GoalServer.Status

  plug :scrub_params, "user" when action in [:create, :update]

  def index(conn, _params) do
    users = Repo.all(User)
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    auth = get_session(conn, :auth)
    changeset = User.changeset(%User{}, %{nick: auth.info.nick})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    changeset = User.changeset(%User{}, user_params)
    ret = if changeset.valid? do
      Repo.transaction(fn ->
        user = Repo.insert!(changeset)
        auth = get_session(conn, :auth)
        |> Map.put(:user_id, user.id)
        provider = Ecto.build_assoc(
          user, :providers, %{
            uid: auth.uid,
            name: auth.provider,
            access_token: auth.credentials.token,
            access_token_secret: auth.credentials.secret
          }
        )
        Repo.insert!(provider)

        goal = Goal.changeset(%Goal{}, %{
          title: user.nick,
          status_id: 0,
          position: 0,
        }) |> Repo.insert!

        Membership.changeset(%Membership{}, %{
          goal_id: goal.id,
          user_id: user.id,
          status: "authorized"
        }) |> Repo.insert!

        Status.changeset(%Status{}, %{
          name: "Close",
          position: -1,
          enable: true,
          goal_id: goal.id
        }) |> Repo.insert!
        Status.changeset(%Status{}, %{
          name: "ToDo",
          position: 1,
          enable: true,
          goal_id: goal.id
        }) |> Repo.insert!
        Status.changeset(%Status{}, %{
          name: "Doing",
          position: 2,
          enable: true,
          goal_id: goal.id
        }) |> Repo.insert!
        Status.changeset(%Status{}, %{
          name: "Done",
          position: 3,
          enable: true,
          goal_id: goal.id
        }) |> Repo.insert!

        [user, goal]
      end)
    else
      {:error, changeset}
    end

    case ret do
      {:ok, [user, root]} ->
        conn
        |> delete_session(:auth)
        |> put_session(:current_user, user)
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: goal_path(conn, :show_html, root.id))
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
