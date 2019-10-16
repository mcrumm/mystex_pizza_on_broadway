defmodule Mix.Tasks.Pizza.Orders do
  use Mix.Task
  @shortdoc "Lists the count of MystexPizza orders"
  import Ecto.Query, only: [from: 1]
  alias MystexPizza.{Order, Repo}

  @impl true
  def run(_args) do
    Application.put_env(:mystex_pizza_on_broadway, :start_pipeline, false)

    {:ok, _} = Application.ensure_all_started(:mystex_pizza_on_broadway)

    count = Repo.aggregate(from(o in Order), :count, :id)

    Mix.shell().info("""
    Mystex Pizza currently has #{count} orders in its database.
    """)
  end
end
