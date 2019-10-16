defmodule MystexPizza.Customer do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :string, []}
  @timestamps_opts type: :utc_datetime_usec
  schema "customers" do
    field(:name, :string, default: "UNKNOWN")
    field(:email)
    field(:phone, :string, default: "UNKNOWN")
    timestamps()
  end

  def changeset(struct \\ %__MODULE__{}, params) do
    struct
    |> cast(params, [:id, :name, :email, :phone])
    |> validate_required([:id, :name, :phone])
  end
end
