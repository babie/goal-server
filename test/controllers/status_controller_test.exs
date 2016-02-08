defmodule GoalServer.StatusControllerTest do
  use GoalServer.ConnCase

  alias GoalServer.Status
  @valid_attrs %{enable: true, name: "some content", position: 42}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, status_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    status = Repo.insert! %Status{}
    conn = get conn, status_path(conn, :show, status)
    assert json_response(conn, 200)["data"] == %{"id" => status.id,
      "name" => status.name,
      "goal_id" => status.goal_id,
      "position" => status.position,
      "enable" => status.enable}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, status_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, status_path(conn, :create), status: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Status, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, status_path(conn, :create), status: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    status = Repo.insert! %Status{}
    conn = put conn, status_path(conn, :update, status), status: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Status, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    status = Repo.insert! %Status{}
    conn = put conn, status_path(conn, :update, status), status: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    status = Repo.insert! %Status{}
    conn = delete conn, status_path(conn, :delete, status)
    assert response(conn, 204)
    refute Repo.get(Status, status.id)
  end
end
