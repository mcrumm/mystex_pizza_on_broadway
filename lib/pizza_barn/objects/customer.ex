defmodule PizzaBarn.Customer do
  def build() do
    %{
      id: Faker.format("cus_######"),
      name: Faker.Name.name(),
      phone: Faker.Phone.EnUs.phone()
    }
  end
end
