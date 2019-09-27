defmodule MysticPizza.NoBatchersPipeline do
  @moduledoc """
  Consumes events from the PizzaBarn producer.

  Processed messages are inserted individually into the database.

  Note: This process is not used within the application, but it provided here
  as an example.

  Check out `MysticPizza.FulfillmentPipeline` for the batching example.
  """
  use Broadway
  alias Broadway.Message
  alias MysticPizza.{Customer, Order, Repo}

  def start_link(_opts) do
    Broadway.start_link(__MODULE__,
      name: __MODULE__,
      producers: [
        default: [
          module: {PizzaBarn.EventProducer, []}
        ]
      ],
      processors: [
        default: [
          stages: 2,
          min_demand: 1,
          max_demand: 2
        ]
      ]
    )
  end

  @impl Broadway
  def handle_message(_processor_name, message, _context) do
    message
    |> Message.update_data(&decode!/1)
    |> process_message()
  end

  defp process_message(%{data: %{"type" => event}} = message) do
    %{data: %{"object" => attrs}} = message

    with [resource, "created"] <- String.split(event, ".", parts: 2),
         {:ok, _struct} <- create(resource, attrs) do
      message
    else
      {:error, reason} ->
        Message.failed(message, reason)

      _ ->
        message
    end
  end

  defp process_message(message), do: message

  defp decode!(data) when is_binary(data) do
    data |> Base.decode64!() |> Jason.decode!()
  end

  defp create("customer", attrs), do: create(Customer, attrs)
  defp create("order", attrs), do: create(Order, attrs)

  defp create(schema, attrs) when is_atom(schema) do
    attrs
    |> schema.changeset()
    |> Repo.insert()
  end

  defp create(schema, _), do: {:error, "#{inspect(schema)} not processed"}
end
