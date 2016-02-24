defmodule GoalServer.GoalControllerTest do
  use GoalServer.ConnCase
  use GoalServer.ControllerHelper, controller: GoalServer.GoalController
  import GoalServer.Fixtures

  alias GoalServer.Goal
  @valid_attrs %{
    title: "some content",
    body: "some content",
    status: 0,
    position: 0,
    parent_id: nil,
  }
  @invalid_attrs %{title: ""}

  setup %{conn: conn} do
    user = fixture(:user)
    root = fixture(:root)
    fixture(:membership, %{user: user, goal: root})
    children = fixture(:children, parent: root)
    |> Enum.map(&(Repo.preload(&1, :parent)))
    {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user, root: root, children: children}
  end

  test "lists all entries on index", %{conn: conn, user: user, root: root} do
    conn = conn
      |> with_session_and_flash
      |> put_session(:current_user, user)
      |> action(:index)
    #conn = get conn, goal_path(conn, :index)
    json_ids = json_response(conn, 200)["data"] |> Enum.map(&(&1["id"]))
    ids = root |> Goal.Queries.self_and_descendants |> Enum.map(&(&1.id))
    assert json_ids == ids
  end

  test "shows chosen resource", %{conn: conn, root: root} do
    conn = get conn, goal_path(conn, :show, root)
    assert json_response(conn, 200)["data"] == %{"id" => root.id,
      "title" => root.title,
      "body" => root.body,
      "status" => root.status,
      "parent_id" => root.parent_id,
      "position" => root.position,
    }
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, goal_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn, root: root, children: children} do
    attrs = Map.merge(@valid_attrs, %{parent_id: root.id, position: 1})
    conn = post conn, goal_path(conn, :create), goal: attrs

    id = json_response(conn, 201)["data"]["id"]
    assert id

    goal = Repo.get(Goal, id)
    assert goal

    root = root |> Repo.preload(:children)
    new_children_ids = root.children |> Enum.sort(&(&1.position < &2.position)) |> Enum.map(&(&1.id))
    children_ids = children |> List.insert_at(1, goal) |> Enum.map(&(&1.id))
    assert new_children_ids == children_ids
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, goal_path(conn, :create), goal: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn, children: [_, c2, _]} do
    attrs = %{title: "bar", body: "hoge", status: 0, parent_id: c2.id, position: c2.position}
    conn = put conn, goal_path(conn, :update, c2), goal: attrs

    id = json_response(conn, 200)["data"]["id"]
    assert id

    goal = Repo.get(Goal, id)
    assert goal
  end

  test "does not update chosen resource and renders errors when data is root", %{conn: conn, root: root} do
    attrs = Map.merge(@valid_attrs, %{body: "bar", parent_id: root.id})
    conn = put conn, goal_path(conn, :update, root), goal: attrs

    assert json_response(conn, 422)["errors"] != %{}
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, root: root} do
    conn = put conn, goal_path(conn, :update, root), goal: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn, children: [_, c2, _]} do
    conn = delete conn, goal_path(conn, :delete, c2)
    assert response(conn, 204)
    refute Repo.get(Goal, c2.id)
  end

  test "copy", %{children: [_, c2, _]} do
    [_, c2_2, _] = fixture(:children, parent: c2)
    tgt_titles = c2 |> Goal.Queries.self_and_descendants |> Enum.map(&(&1.title))

    conn = post conn, goal_path(conn, :copy, c2, %{"dest_parent_id" => c2_2.id, "dest_position" => 0})

    data = json_response(conn, 201)["data"]
    assert data

    dest_titles = data |> Enum.map(&(&1["title"]))
    assert tgt_titles == dest_titles
  end

  test "get roots", %{conn: conn, user: user, root: root} do
    conn = conn
      |> with_session_and_flash
      |> put_session(:current_user, user)
      |> action(:roots)

    ids = [root.id]
    json_ids = json_response(conn, 200)["data"] |> Enum.map(&(&1["id"]))
    assert json_ids == ids
  end

  test "get children", %{conn: conn, root: root, children: children} do
    conn = get conn, goal_path(conn, :children, root.id)

    ids = children |> Enum.map(&(&1.id))
    json_ids = json_response(conn, 200)["data"] |> Enum.map(&(&1["id"]))
    assert json_ids == ids
  end

  test "get parent", %{conn: conn, children: children} do
    goal = List.first children
    conn = get conn, goal_path(conn, :parent, goal)

    parent = goal.parent
    assert json_response(conn, 200)["data"] == %{
      "id" => parent.id,
      "title" => parent.title,
      "body" => parent.body,
      "status" => parent.status,
      "parent_id" => parent.parent_id,
      "position" => parent.position,
    }
  end

  test "get siblings", %{conn: conn, children: children} do
    [c1, c2, c3] = children
    conn = get conn, goal_path(conn, :siblings, c2)

    ids = [c1, c3] |> Enum.map(&(&1.id))
    json_ids = json_response(conn, 200)["data"] |> Enum.map(&(&1["id"]))
    assert json_ids == ids
  end

end
