defmodule PizzaBarn.Order do
  def build() do
    %{
      id: Faker.format("ord_######"),
      customer: Faker.format("cus_######"),
      amount: price_in_cents(),
      email: Enum.random(["", Faker.Internet.safe_email()]),
      currency: "usd"
    }
  end

  defp price_in_cents do
    round(Faker.Commerce.price() * 1_000)
  end
end
