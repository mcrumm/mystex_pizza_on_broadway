defmodule MystexPizzaTest do
  use ExUnit.Case
  doctest MystexPizza

  test "greets the world" do
    assert MystexPizza.hello() == :world
  end
end
