defmodule GoalServer.AuthController do
  use GoalServer.Web, :controller
  plug Ueberauth

  alias GoalServer.Provider

  def callback(%{ assigns: %{ ueberauth_failure: _fails } } = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: "/")
  end

  def callback(%{ assigns: %{ ueberauth_auth: auth } } = conn, params) do
    auth = %{
      uid: auth.uid,
      provider: params["provider"],
      info: %{
        nick: auth.info.nickname
      },
      credentials: %{
        token: auth.credentials.token,
        secret: auth.credentials.secret
      }
    }
    provider = Repo.get_by(Provider, name: auth.provider, uid: auth.uid)
    if provider do
      provider = provider
      |> Repo.preload([user: [:roots]])
      root = provider.user.roots |> List.first
      conn
      |> put_session(:current_user, provider.user)
      |> redirect(to: goal_path(conn, :show_html, root.id))
    else
      conn
      |> put_flash(:info, "Successfully authenticated.")
      |> put_session(:auth, auth)
      |> redirect(to: user_path(conn, :new))
    end
  end
end
