defmodule MystexPizza.Order do
  @moduledoc """
  The schema for an Order from PizzaBarn.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, []}
  @timestamps_opts type: :utc_datetime_usec
  schema "orders" do
    field(:amount, :integer)
    belongs_to(:customer, MystexPizza.Customer, type: :string)
    timestamps()
  end

  @doc false
  def changeset(struct \\ %__MODULE__{}, params) do
    struct
    |> cast(params, [:id, :amount])
    |> validate_required([:id, :amount])
    |> assoc_constraint(:customer)
  end
end
