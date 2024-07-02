defmodule BrainfeedTest do
  use ExUnit.Case
  doctest Brainfeed

  test "greets the world" do
    assert Brainfeed.hello() == :world
  end
end
