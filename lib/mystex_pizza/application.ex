defmodule MystexPizza.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {MystexPizza.Repo, []}
    ]

    children =
      if Application.get_env(:mystex_pizza_on_broadway, :start_pipeline, true) do
        children ++ [{MystexPizza.FulfillmentPipeline, []}]
      else
        children
      end

    opts = [strategy: :one_for_one, name: MystexPizza.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
