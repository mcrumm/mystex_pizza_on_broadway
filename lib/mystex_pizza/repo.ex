defmodule MystexPizza.Repo do
  use Ecto.Repo,
    otp_app: :mystex_pizza_on_broadway,
    adapter: Ecto.Adapters.Postgres
end
