defmodule MysticPizza.FulfillmentPipeline do
  @moduledoc """
  Consumes events from the PizzaBarn producer.

  Processed messages are batched and stored as entries in the database.
  """
  use Broadway
  alias Broadway.{BatchInfo, Message}
  alias Ecto.Changeset
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
      ],
      batchers: [
        default: [],
        insert_all: [
          batch_size: 50,
          batch_timeout: 1_000
        ]
      ]
    )
  end

  @impl Broadway
  def handle_message(_processor_name, message, _context) do
    message
    |> Message.update_data(&decode!/1)
    |> pre_process_message()
    |> process_message()
  end

  defp pre_process_message(
         %Message{data: %{"type" => "order.created"}} = message
       ) do
    %{data: %{"object" => %{"customer" => customer_id}}} = message

    customer = %Customer{id: customer_id}
    changeset = Customer.changeset(customer, %{})

    case Repo.insert(changeset, on_conflict: :nothing) do
      {:ok, _} ->
        message

      {:error, _} ->
        Message.failed(message, "Could not preprocess customer #{customer_id}")
    end
  end

  defp pre_process_message(%Message{} = message), do: message

  defp process_message(%Message{data: %{"type" => event}} = message) do
    # Route the messages to the proper batcher
    case batching(event) do
      :default ->
        message

      {batcher, batch_key} when is_atom(batcher) ->
        message
        |> Message.put_batcher(batcher)
        |> Message.put_batch_key(batch_key)
    end
  end

  defp process_message(%Message{} = message), do: message

  defp decode!(data) when is_binary(data) do
    data |> Base.decode64!() |> Jason.decode!()
  end

  defp batching("customer.created"), do: {:insert_all, Customer}
  defp batching("order.created"), do: {:insert_all, Order}
  defp batching(_), do: :default

  @impl Broadway
  def handle_batch(:insert_all, messages, %BatchInfo{batch_key: Customer}, _) do
    batch_insert_all(Customer, messages,
      on_conflict: :replace_all_except_primary_key,
      conflict_target: [:id]
    )
  end

  def handle_batch(:insert_all, messages, %BatchInfo{batch_key: schema}, _) do
    batch_insert_all(schema, messages)
  end

  # Ensure all other batches get acknowledged
  def handle_batch(_, messages, _, _), do: messages

  defp batch_insert_all(schema, messages, opts \\ []) do
    entries = convert_batch_to_entries(schema, messages)

    case Repo.insert_all(schema, entries, opts) do
      {n, _} when n == length(entries) ->
        messages

      result ->
        batch_failed(messages, {:insert_all, schema, result})
    end
  end

  # Schemas with foreign keys need to be handled individually
  defp convert_batch_to_entries(Order, messages) do
    Enum.map(messages, fn %Message{data: %{"object" => attrs}} ->
      {customer_id, attrs} = Map.pop(attrs, "customer")

      %Changeset{changes: changes} =
        %Order{}
        |> Order.changeset(attrs)
        |> Changeset.put_change(:customer_id, customer_id)

      Map.merge(changes, timestamps(Order))
    end)
  end

  # This converter should apply to any simple schemas
  defp convert_batch_to_entries(schema, messages) do
    Enum.map(messages, fn %Message{data: %{"object" => attrs}} ->
      %Changeset{changes: changes} =
        schema
        |> struct!()
        |> schema.changeset(attrs)

      Map.merge(changes, timestamps(schema))
    end)
  end

  defp timestamps(_) do
    now = DateTime.utc_now()
    %{inserted_at: now, updated_at: now}
  end

  defp batch_failed(messages, reason) when is_list(messages) do
    Enum.map(messages, &Message.failed(&1, reason))
  end
end
