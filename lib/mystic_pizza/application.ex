defmodule MysticPizza.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {MysticPizza.Repo, []}
    ]

    children =
      if Application.get_env(:mystic_pizza_on_broadway, :start_pipeline, true) do
        children ++ [{MysticPizza.FulfillmentPipeline, []}]
      else
        children
      end

    opts = [strategy: :one_for_one, name: MysticPizza.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
