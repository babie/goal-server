defmodule GoalServer.Model.Util do
  defmacro __using__(_opts) do
    quote do
      defp load_into(response, model) do
        Enum.map response.rows, fn(row) ->
          fields = Enum.reduce(
            Enum.zip(response.columns, row),
            %{},
            fn({key, value}, map) -> Map.put(map, key, value) end
          )

          Ecto.Schema.__load__(
            model, nil, nil, [], fields, &GoalServer.Repo.__adapter__.load/2
          )
        end
      end
    end
  end
end
