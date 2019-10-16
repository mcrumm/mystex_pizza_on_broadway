defmodule MystexPizza.MixProject do
  use Mix.Project

  def project do
    [
      app: :mystex_pizza_on_broadway,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {MystexPizza.Application, []}
    ]
  end

  defp deps do
    [
      {:broadway, "~> 0.4.0"},
      {:ecto, "~> 3.2"},
      {:ecto_sql, "~> 3.2"},
      {:postgrex, ">= 0.0.0"},
      {:jason, "~> 1.1"},
      {:faker, "~> 0.12.0"}
    ]
  end

  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
