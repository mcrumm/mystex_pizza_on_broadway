use Mix.Config

config :mystic_pizza_on_broadway, MysticPizza.Repo,
  username: "postgres",
  password: "postgres",
  database: "mystic_pizza_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
