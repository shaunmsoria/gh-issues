defmodule CliTest do
  use ExUnit.Case

  doctest Sstest

  import Sstest.CLI, only: [parse_args: 1]

  test ":help returned when argurment -h or --help is provided" do
    assert parse_args(["-h", "anything"]) == :help
    assert parse_args(["--help", "anything"]) == :help
  end

  test "count is returned when provided" do
    assert parse_args(["user", "project", "99"]) == {"user", "project", 99}
  end

  test "default count is returned when no count is provided" do
    assert parse_args(["user", "project"]) == {"user", "project", 4}
  end
end
