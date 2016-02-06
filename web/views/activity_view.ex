defmodule GoalServer.ActivityView do
  use GoalServer.Web, :view

  def render("index.json", %{activities: activities}) do
    %{data: render_many(activities, GoalServer.ActivityView, "activity.json")}
  end

  def render("show.json", %{activity: activity}) do
    %{data: render_one(activity, GoalServer.ActivityView, "activity.json")}
  end

  def render("activity.json", %{activity: activity}) do
    %{id: activity.id,
      goal_id: activity.goal_id,
      user_id: activity.user_id,
      backup: activity.backup,
      diff: activity.diff}
  end
end
