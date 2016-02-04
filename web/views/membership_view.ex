defmodule GoalServer.MembershipView do
  use GoalServer.Web, :view

  def render("index.json", %{memberships: memberships}) do
    %{data: render_many(memberships, GoalServer.MembershipView, "membership.json")}
  end

  def render("show.json", %{membership: membership}) do
    %{data: render_one(membership, GoalServer.MembershipView, "membership.json")}
  end

  def render("membership.json", %{membership: membership}) do
    %{id: membership.id,
      user_id: membership.user_id,
      project_id: membership.project_id,
      status: membership.status}
  end
end
