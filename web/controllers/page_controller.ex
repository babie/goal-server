defmodule GoalServer.PageController do
  use GoalServer.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def columned_treeview(conn, _params) do
    render conn, "columned_treeview.html"
  end
end
