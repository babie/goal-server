defmodule GoalServer.Github do
  use OAuth2.Strategy

  def client do
    OAuth2.Client.new([
      strategy: __MODULE__,
      client_id: System.get_env("GITHUB_CLIENT_ID"),
      client_secret: System.get_env("GITHUB_CLIENT_SECRET"),
      redirect_uri: System.get_env("GITHUB_CALLBACK_URI"),
      site: "https://api.github.com",
      authorize_url: "https://github.com/login/oauth/authorize",
      token_url: "https://github.com/login/oauth/access_token"
    ])
  end

  def authorize_url!(params \\ []) do
    client()
    |> put_param(:scope, "user,public_repo")
    |> OAuth2.Client.authorize_url!(params)
  end

  def get_token!(params \\ [], headers \\ [], options \\ []) do
    kl_params = Enum.map(params, fn {k,v} -> {String.to_atom(k), v} end)
    OAuth2.Client.get_token!(client(), kl_params, headers, options)
  end

  def get_user!(token) do
    user = OAuth2.AccessToken.get!(token, "/user").body

    %{
      nick: user["login"],
      auth: %{
        uid: Integer.to_string(user["id"]),
        provider: "github",
        oauth_token: token.access_token,
        oauth_token_secret: ""
      }
    }
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> put_header("Accept", "application/json")
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end
