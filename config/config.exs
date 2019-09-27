use Mix.Config

config :mystic_pizza_on_broadway, ecto_repos: [MysticPizza.Repo]

import_config "#{Mix.env()}.exs"
