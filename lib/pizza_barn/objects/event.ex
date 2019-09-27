defmodule PizzaBarn.Event do
  def build(object_module, action)
      when is_atom(object_module) and (is_atom(action) or is_binary(action)) do
    event_type = "#{module_to_string(object_module)}.#{action}"
    object = object_module.build()

    %{type: event_type, object: object}
  end

  defp module_to_string(module) when is_atom(module) do
    module |> Module.split() |> Enum.reverse() |> hd() |> String.downcase()
  end
end
