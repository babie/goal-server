defmodule GoalServer.MembershipControllerTest do
  use GoalServer.ConnCase
  import GoalServer.Fixtures

  alias GoalServer.Membership
  @valid_attrs %{status: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    project = fixture(:project)
    user = fixture(:user)
    {:ok, conn: put_req_header(conn, "accept", "application/json"), project: project, user: user}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, membership_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    membership = Repo.insert! %Membership{}
    conn = get conn, membership_path(conn, :show, membership)
    assert json_response(conn, 200)["data"] == %{"id" => membership.id,
      "user_id" => membership.user_id,
      "project_id" => membership.project_id,
      "status" => membership.status}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, membership_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn, project: project, user: user} do
    attrs = Map.merge(@valid_attrs, %{project_id: project.id, user_id: user.id})
    conn = post conn, membership_path(conn, :create), membership: attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Membership, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, membership_path(conn, :create), membership: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn, project: project, user: user} do
    membership = Repo.insert! %Membership{}
    attrs = Map.merge(@valid_attrs, %{project_id: project.id, user_id: user.id})
    conn = put conn, membership_path(conn, :update, membership), membership: attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Membership, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    membership = Repo.insert! %Membership{}
    conn = put conn, membership_path(conn, :update, membership), membership: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    membership = Repo.insert! %Membership{}
    conn = delete conn, membership_path(conn, :delete, membership)
    assert response(conn, 204)
    refute Repo.get(Membership, membership.id)
  end
end
