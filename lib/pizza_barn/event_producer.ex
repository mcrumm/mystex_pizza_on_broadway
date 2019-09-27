defmodule PizzaBarn.EventProducer do
  use GenStage
  alias PizzaBarn.Events

  @behaviour Broadway.Acknowledger

  @impl GenStage
  def init(opts) do
    {:producer, opts}
  end

  @impl GenStage
  def handle_demand(demand, opts) do
    messages = demand |> gen_events(opts) |> to_messages()

    {:noreply, messages, opts}
  end

  defp gen_events(num_events, opts) do
    Enum.map(1..num_events, &gen_event_encoded(&1, opts))
  end

  defp gen_event_encoded(k, opts) do
    k |> gen_event(opts) |> Jason.encode!() |> Base.encode64()
  end

  defp gen_event(_k, opts) do
    Events.generate(opts)
  end

  defp to_messages(users), do: to_messages(users, [])
  defp to_messages([], messages), do: messages

  defp to_messages([data | rest], messages) do
    message = %Broadway.Message{
      data: data,
      acknowledger: {__MODULE__, :ack_ref, :ack_id}
    }

    to_messages(rest, [message | messages])
  end

  @impl Broadway.Acknowledger
  def ack(_, _, []), do: :ok

  def ack(_ack_ref, _successful, failed) do
    reasons =
      failed
      |> Enum.map(fn %{
                       batcher: batcher,
                       batch_key: key,
                       status: {:failed, reason}
                     } ->
        {key, batcher, reason}
      end)
      |> Enum.uniq()

    IO.inspect(reasons, label: "FAILURES")

    :ok
  end
end
