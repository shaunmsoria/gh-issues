defmodule SstestTest do
  use ExUnit.Case
  doctest Sstest

  test "greets the world" do
    assert Sstest.hello() == :world
  end
end
