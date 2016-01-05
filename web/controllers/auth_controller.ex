defmodule GoalServer.AuthController do
  use GoalServer.Web, :controller

  alias GoalServer.Twitter
  alias GoalServer.Github

  def index(conn, %{"provider" => provider}) do
    callback_url = auth_url(conn, :callback, "twitter")
    redirect conn, external: authorize_url!(provider, callback_url)
  end

  def callback(conn, %{"provider" => provider} = params) do
    token = get_token!(provider, params)
    user = get_user!(provider, token)

    conn
    |> put_session(:tmp_user, user)
    |> redirect(to: user_path(conn, :new))
  end

  defp authorize_url!("twitter", callback_url), do: Twitter.authorize_url!(callback_url)
  defp authorize_url!("github", callback_url), do: Github.authorize_url!()
  defp authorize_url!(_, _), do: raise "No matching provider available"

  defp get_token!("twitter", params), do: Twitter.get_token!(params)
  defp get_token!("github", params), do: Github.get_token!(params)
  defp get_token!(_,_), do: raise "No matching provider available"

  defp get_user!("twitter", token), do: Twitter.get_user!(token)
  defp get_user!("github", token), do: Github.get_user!(token)
end
