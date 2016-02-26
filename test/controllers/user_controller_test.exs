defmodule GoalServer.UserControllerTest do
  use GoalServer.ConnCase
  use GoalServer.ControllerHelper, controller: GoalServer.UserController

  alias GoalServer.User
  @valid_attrs %{nick: "some content"}
  @invalid_attrs %{}
  @valid_auth %{
    uid: "111111111111",
    provider: "twitter",
    info: %{
      nick: "test_user"
    },
    credentials: %{
      token: "asdfghjkl",
      secret: "zxcvbnm"
    }
  }

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, user_path(conn, :index)
    assert html_response(conn, 200) =~ "Listing users"
  end

  test "renders form for new resources", %{conn: conn} do
    conn = conn
      |> with_session_and_flash
      |> put_session(:auth, @valid_auth)
      |> action(:new, %{})
    #conn = get conn, user_path(conn, :new)
    assert html_response(conn, 200) =~ "New user"
  end

  test "creates resource and redirects when data is valid", %{conn: conn} do
    conn = conn
      |> with_session_and_flash
      |> put_session(:auth, @valid_auth)
      |> action(:create, %{"user" => @valid_attrs})
    #conn = post conn, user_path(conn, :create), user: @valid_attrs
    user = Repo.get_by(User, @valid_attrs)
    assert user

    membership = GoalServer.Membership
                  |> Repo.get_by(user_id: user.id)
                  |> Repo.preload([:goal])
    assert membership

    root = membership.goal
    assert root
    assert redirected_to(conn) == goal_path(conn, :show_html, root.id)

    statuses = GoalServer.Status |> Repo.all |> Enum.sort(&(&1.position < &2.position)) |> Enum.map(&(&1.name))

    assert statuses == ["Close", "ToDo", "Doing", "Done"]
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = conn
      |> with_session_and_flash
      |> put_session(:auth, @valid_auth)
      |> action(:create, %{"user" => @invalid_attrs})
    #conn = post conn, user_path(conn, :create), user: @invalid_attrs
    assert html_response(conn, 200) =~ "New user"
  end

  test "shows chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :show, user)
    assert html_response(conn, 200) =~ "Show user"
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, user_path(conn, :show, -1)
    end
  end

  test "renders form for editing chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = get conn, user_path(conn, :edit, user)
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "updates chosen resource and redirects when data is valid", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), user: @valid_attrs
    assert redirected_to(conn) == user_path(conn, :show, user)
    assert Repo.get_by(User, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = put conn, user_path(conn, :update, user), user: @invalid_attrs
    assert html_response(conn, 200) =~ "Edit user"
  end

  test "deletes chosen resource", %{conn: conn} do
    user = Repo.insert! %User{}
    conn = delete conn, user_path(conn, :delete, user)
    assert redirected_to(conn) == user_path(conn, :index)
    refute Repo.get(User, user.id)
  end
end
