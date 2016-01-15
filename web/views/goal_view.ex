defmodule GoalServer.GoalView do
  use GoalServer.Web, :view

  def render("index.json", %{goals: goals}) do
    %{data: render_many(goals, GoalServer.GoalView, "goal.json")}
  end

  def render("show.json", %{goal: goal}) do
    %{data: render_one(goal, GoalServer.GoalView, "goal.json")}
  end

  def render("goal.json", %{goal: goal}) do
    %{id: goal.id,
      title: goal.title,
      body: goal.body,
      status: goal.status,
      position: goal.position,
      owned_by: goal.owned_by,
      inserted_by: goal.inserted_by,
      updated_by: goal.updated_by}
  end
end
