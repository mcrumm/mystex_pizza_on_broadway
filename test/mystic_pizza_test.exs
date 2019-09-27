defmodule MysticPizzaTest do
  use ExUnit.Case
  doctest MysticPizza

  test "greets the world" do
    assert MysticPizza.hello() == :world
  end
end
