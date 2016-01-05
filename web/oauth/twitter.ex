defmodule GoalServer.Twitter do
  @moduledoc """
  Sign In strategy for Twitter
  """

  def new(opts \\ []) do
    config = Keyword.merge(
      [
        consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
        consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET"),
        access_token: "",
        access_token_secret: ""
      ],
      opts
    )
    ExTwitter.configure(:process, config)
  end

  def authorize_url!() do
    new()
    token = ExTwitter.request_token(System.get_env("TWITTER_CALLBACK_URI"))
    {:ok, authenticate_url} = ExTwitter.authenticate_url(token.oauth_token)
    authenticate_url
  end

  def get_token!(%{"oauth_verifier" => oauth_verifier, "oauth_token" => oauth_token} = _params \\ [], _headers \\ [], _options \\ []) do
    new()
    {:ok, access_token} = ExTwitter.access_token(oauth_verifier, oauth_token)
    access_token
  end

  def get_user!(token) do
    new(
      access_token: token.oauth_token,
      access_token_secret: token.oauth_token_secret
    )
    user = ExTwitter.verify_credentials
    %{
      nick: user.screen_name,
      auth: %{
        uid: user.id_str,
        provider: "twitter",
        oauth_token: token.oauth_token,
        oauth_token_secret: token.oauth_token_secret
      }
    }
  end

end
