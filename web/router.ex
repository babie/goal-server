defmodule GoalServer.Router do
  use GoalServer.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    # for user authentication
    plug :assign_current_user
  end

  defp assign_current_user(conn, _) do
    assign(conn, :current_user, get_session(conn, :current_user))
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GoalServer do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/columned-treeview", PageController, :columned_treeview
    resources "/users", UserController
    get "/goals/:id", GoalController, :show_html
  end

  scope "/auth", GoalServer do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
  end

  # Other scopes may use custom stacks.
  scope "/api", GoalServer do
    pipe_through :api

    get "/goals/roots", GoalController, :roots
    resources "/goals", GoalController, except: [:new, :edit]
    post "/goals/:target_id/copy", GoalController, :copy
    get "/goals/:id/children", GoalController, :children
    get "/goals/:id/parent", GoalController, :parent
    get "/goals/:id/siblings", GoalController, :siblings
    resources "/memberships", MembershipController, except: [:new, :edit]
    resources "/statuses", StatusController, except: [:new, :edit]
    resources "/activities", ActivityController, except: [:new, :edit]
  end
end
