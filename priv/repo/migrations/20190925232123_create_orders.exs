defmodule MystexPizza.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders, primary_key: false) do
      add :id, :string, primary_key: true
      add :customer_id, references(:customers, type: :string)
      add :amount, :integer, null: false
      timestamps(type: :utc_datetime_usec)
    end
  end
end
