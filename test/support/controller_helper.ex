defmodule GoalServer.ControllerHelper do
  defmacro __using__(args) do
    controller = Keyword.get(args, :controller)

    quote bind_quoted: [controller: controller] do
      use Plug.Test

      @controller controller

      def action(conn, action, params \\ %{}) do
        conn = conn
          |> put_private(:phoenix_controller, @controller)
          |> Phoenix.Controller.put_view(Phoenix.Controller.__view__(@controller))

        apply(@controller, action, [conn, params])
      end

      @session Plug.Session.init(
        store: :cookie,
        key: "_app",
        encryption_salt: "yadayada",
        signing_salt: "yadayada"
      )

      defp with_session_and_flash(conn) do
        conn
        |> Map.put(:secret_key_base, String.duplicate("abcdefgh", 8))
        |> Plug.Session.call(@session)
        |> Plug.Conn.fetch_session()
        |> Phoenix.ConnTest.fetch_flash()
      end
    end
  end
end
