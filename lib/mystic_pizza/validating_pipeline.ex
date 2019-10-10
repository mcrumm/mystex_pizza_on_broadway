defmodule MysticPizza.ValidatingPipeline do
  @moduledoc """
  Consumes events from the PizzaBarn producer.

  Message data is validated in the `processors`.

  Valid messages are sent to the `batchers` for insertion in the database.
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
    |> process_message()
    |> post_process_message()
  end

  defp decode!(data) when is_binary(data) do
    data |> Base.decode64!() |> Jason.decode!()
  end

  defp process_message(%Message{data: %{"type" => event}} = message) do
    message
    |> maybe_build_changeset(event)
    |> validate_changeset()
    |> pick_batcher()
  end

  defp process_message(%Message{} = message), do: message

  defp maybe_build_changeset(message, "order.created") do
    Message.update_data(message, fn %{"object" => attrs} ->
      {customer_id, attrs} = Map.pop(attrs, "customer")

      %Order{}
      |> Order.changeset(attrs)
      |> Changeset.put_change(:customer_id, customer_id)
    end)
  end

  defp maybe_build_changeset(message, "customer.created") do
    Message.update_data(message, fn %{"object" => attrs} ->
      Customer.changeset(%Customer{}, attrs)
    end)
  end

  defp maybe_build_changeset(message, _), do: message

  defp validate_changeset(
         %Message{data: %Changeset{valid?: false, errors: errors}} = message
       ) do
    Message.failed(message, errors)
  end

  defp validate_changeset(message), do: message

  defp pick_batcher(
         %Message{data: %Changeset{data: %schema{}, action: action}} = message
       )
       when action in [nil, :insert] do
    message
    |> Message.put_batcher(:insert_all)
    |> Message.put_batch_key(schema)
  end

  defp pick_batcher(message), do: message

  defp post_process_message(
         %Message{status: :ok, data: %Changeset{data: %Order{}} = order} =
           message
       ) do
    with id when not is_nil(id) <- Changeset.get_field(order, :customer_id),
         changeset = Changeset.change(%Customer{id: id}, %{}),
         {:ok, _} <- Repo.insert(changeset, on_conflict: :nothing) do
      message
    else
      nil ->
        Message.failed(message, "Customer ID not set on Order")

      _ ->
        Message.failed(message, "Could not preprocess Customer")
    end
  end

  defp post_process_message(%Message{} = message), do: message

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
    entries =
      Enum.map(messages, fn %Message{data: %Changeset{changes: changes}} ->
        Map.merge(changes, timestamps(schema))
      end)

    case Repo.insert_all(schema, entries, opts) do
      {n, _} when n == length(entries) ->
        messages

      result ->
        batch_failed(messages, {:insert_all, schema, result})
    end
  end

  defp timestamps(_) do
    now = DateTime.utc_now()
    %{inserted_at: now, updated_at: now}
  end

  defp batch_failed(messages, reason) when is_list(messages) do
    Enum.map(messages, &Message.failed(&1, reason))
  end
end
