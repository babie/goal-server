defmodule GoalServer.StatusView do
  use GoalServer.Web, :view

  def render("index.json", %{statuses: statuses}) do
    %{data: render_many(statuses, GoalServer.StatusView, "status.json")}
  end

  def render("show.json", %{status: status}) do
    %{data: render_one(status, GoalServer.StatusView, "status.json")}
  end

  def render("status.json", %{status: status}) do
    %{id: status.id,
      name: status.name,
      project_id: status.project_id,
      position: status.position,
      enable: status.enable}
  end
end
