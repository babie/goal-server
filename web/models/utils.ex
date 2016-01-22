defmodule GoalServer.Model.Utils do
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

      defp load(response, fields) do
        fields = Enum.map(fields, fn(f) ->
          cond do
            is_atom(f) -> Atom.to_string(f)
            is_binary(f) -> f
          end
        end)
        Enum.map response.rows, fn(row) ->
          Enum.reduce(
            Enum.zip(response.columns, row),
            [],
            fn({key, value}, keywords) ->
              if Enum.any?(fields, fn(f) -> f == key end) do
                keywords = Keyword.put(keywords, String.to_atom(key), value)
              end
              keywords
            end
          )
        end
      end
    end
  end
end
