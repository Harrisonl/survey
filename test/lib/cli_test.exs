defmodule Survey.CLITest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  alias Survey.{CLI, State}

  @valid_args ["--questions", "test.csv", "--answers", "answers.csv"]

  test "should error if the files can't be processed" do
    assert capture_io(fn -> CLI.main(["--questions", "hello"]) end) == "Missing answers file\n"
    assert capture_io(fn -> CLI.main([]) end) == "Missing valid questions and answers file\n"
  end

  test "should error if the data can't be analysed" do
  end

  test "should display the results table if the data is fine" do
  end

end
