defmodule MystexPizza.Repo.Migrations.CreateCustomers do
  use Ecto.Migration

  def change do
    create table(:customers, primary_key: false) do
      add :id, :string, primary_key: true
      add :name, :string, null: false
      add :email, :string
      add :phone, :string, null: false

      timestamps(type: :utc_datetime_usec)
    end
  end
end
