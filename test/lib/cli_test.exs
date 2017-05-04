defmodule Survey.CLITest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  test "should out hello world" do
    assert capture_io(fn -> Survey.CLI.main("") end) == "Hello World\n"
  end
end
