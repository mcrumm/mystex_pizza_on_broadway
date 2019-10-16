use Mix.Config

config :mystex_pizza_on_broadway, ecto_repos: [MystexPizza.Repo]

import_config "#{Mix.env()}.exs"
