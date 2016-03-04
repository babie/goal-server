defmodule GoalServer.PageController do
  use GoalServer.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
