ExUnit.start

Mix.Task.run "ecto.create", ~w(-r GoalServer.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r GoalServer.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(GoalServer.Repo)

