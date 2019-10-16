use Mix.Config

config :mystex_pizza_on_broadway, MystexPizza.Repo,
  username: "postgres",
  password: "postgres",
  database: "mystex_pizza_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
