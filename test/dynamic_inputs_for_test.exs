defmodule DynamicInputsForTest do
  use ExUnit.Case
  doctest DynamicInputsFor

  test "greets the world" do
    assert DynamicInputsFor.hello() == :world
  end
end
