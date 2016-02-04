defmodule GoalServer.GoalView do
  use GoalServer.Web, :view

  def render("index.json", %{goals: goals}) do
    %{data: render_many(goals, GoalServer.GoalView, "goal.json")}
  end

  def render("show.json", %{goal: goal}) do
    %{data: render_one(goal, GoalServer.GoalView, "goal.json")}
  end

  def render("goal.json", %{goal: goal}) do
    %{
      id: goal.id,
      title: goal.title,
      body: goal.body,
      status: goal.status,
      parent_id: goal.parent_id,
      position: goal.position,
      project_id: goal.project_id,
    }
  end

  def render("error.json", %{exception: exception}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    %{errors: exception.message}
  end
end
