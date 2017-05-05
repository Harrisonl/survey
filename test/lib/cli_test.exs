defmodule Survey.CLITest do
  use TestHelper
  import ExUnit.CaptureIO
  alias Survey.{CLI, State}

  setup do
    questions = "./test/questions_sample.csv"
    answers = "./test/answers_sample.csv"
    {:ok, questions: questions, answers: answers}
  end

  test "should error if the files can't be processed" do
    assert capture_io(fn -> CLI.main(["--questions", "hello"]) end) == "Missing answers file\n"
    assert capture_io(fn -> CLI.main([]) end) == "Missing valid questions and answers file\n"
  end

  test "should display the results table if the data is fine", %{questions: questions, answers: answers} do
    output = capture_io(fn -> CLI.main(["--questions", questions, "--answers", answers]) end)
    assert output =~ "Summary"
    assert output =~ "Questions"
    assert output =~ "Answers"
    assert output =~ "Averages"
  end

  test "the final state should be complete", %{questions: questions, answers: answers} do
    capture_io(fn -> CLI.main(["--questions", questions, "--answers", answers]) end)
    assert State.current == {:displaying, :complete}
  end
end
