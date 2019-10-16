defmodule Mix.Tasks.Pizza.Customers do
  use Mix.Task
  @shortdoc "Lists the count of MystexPizza customers"
  import Ecto.Query, only: [from: 1]
  alias MystexPizza.{Customer, Repo}

  @impl true
  def run(_args) do
    Application.put_env(:mystex_pizza_on_broadway, :start_pipeline, false)

    {:ok, _} = Application.ensure_all_started(:mystex_pizza_on_broadway)

    count = Repo.aggregate(from(c in Customer), :count, :id)

    Mix.shell().info("""
    Mystex Pizza currently has #{count} customers in its database.
    """)
  end
end
