defmodule GoalServer.ActivityControllerTest do
  use GoalServer.ConnCase

  alias GoalServer.Activity
  @valid_attrs %{backup: %{}, diff: %{}}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, activity_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    activity = Repo.insert! %Activity{}
    conn = get conn, activity_path(conn, :show, activity)
    assert json_response(conn, 200)["data"] == %{"id" => activity.id,
      "goal_id" => activity.goal_id,
      "user_id" => activity.user_id,
      "backup" => activity.backup,
      "diff" => activity.diff}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, activity_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, activity_path(conn, :create), activity: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Activity, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, activity_path(conn, :create), activity: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    activity = Repo.insert! %Activity{}
    conn = put conn, activity_path(conn, :update, activity), activity: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Activity, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    activity = Repo.insert! %Activity{}
    conn = put conn, activity_path(conn, :update, activity), activity: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    activity = Repo.insert! %Activity{}
    conn = delete conn, activity_path(conn, :delete, activity)
    assert response(conn, 204)
    refute Repo.get(Activity, activity.id)
  end
end
