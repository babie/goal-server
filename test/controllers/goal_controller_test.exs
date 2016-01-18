defmodule GoalServer.GoalControllerTest do
  use GoalServer.ConnCase
  import GoalServer.Fixtures

  alias GoalServer.Goal
  @valid_attrs %{
    title: "some content",
    body: "some content",
    status: "todo",
    position: 0,
    parent_id: nil,
    owned_by: 42,
  }
  @invalid_attrs %{title: "", owned_by: -1}

  setup %{conn: conn} do
    user = fixture(:user)
    root = fixture(:root, user: user)
    children = fixture(:children, parent: root)
    |> Enum.map(&(Repo.preload(&1, :parent)))
    {:ok, conn: put_req_header(conn, "accept", "application/json"), user: user, root: root, children: children}
  end

  test "lists all entries on index", %{conn: conn, root: root, children: children} do
    conn = get conn, goal_path(conn, :index)
    json_ids = json_response(conn, 200)["data"] |> Enum.map(&(&1["id"]))
    ids = [root|children] |> Enum.map(&(&1.id))
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
      "owned_by" => root.owned_by,
    }
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, goal_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn, user: user, root: root, children: children} do
    attrs = Map.merge(@valid_attrs, %{parent_id: root.id, position: 1, owned_by: user.id})
    conn = post conn, goal_path(conn, :create), goal: attrs

    id = json_response(conn, 201)["data"]["id"]
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

  test "updates and renders chosen resource when data is valid", %{conn: conn, user: user, root: root} do
    goal_map = Map.merge(@valid_attrs, %{body: "hoge", owned_by: user.id})
    conn = put conn, goal_path(conn, :update, root), goal: goal_map
    id = json_response(conn, 200)["data"]["id"]
    assert id
    assert Repo.get_by(Goal, id: id)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn, root: root} do
    conn = put conn, goal_path(conn, :update, root), goal: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn, root: root} do
    conn = delete conn, goal_path(conn, :delete, root)
    assert response(conn, 204)
    refute Repo.get(Goal, root.id)
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
      "owned_by" => parent.owned_by,
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
