defmodule PizzaBarn.Events do
  alias PizzaBarn.{Customer, Event, Order}

  @all_objects [Customer, Order]
  @default_actions [:created, :updated, :deleted]
  @object_actions [
    {Order, [:created, :cancelled]}
  ]

  def generate(opts \\ []) do
    object_module = get_random_object(opts)
    action_type = get_random_action(object_module)
    Event.build(object_module, action_type)
  end

  defp get_random_object(opts) do
    opts |> Keyword.get(:objects, @all_objects) |> Enum.random()
  end

  defp get_random_action(object), do: Enum.random(get_actions(object))
  defp get_actions(object), do: @object_actions[object] || @default_actions
end
