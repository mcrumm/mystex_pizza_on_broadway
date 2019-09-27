defmodule MysticPizza.Repo do
  use Ecto.Repo,
    otp_app: :mystic_pizza_on_broadway,
    adapter: Ecto.Adapters.Postgres
end
