defmodule Survey.ParserTest do
  use ExUnit.Case, async: false
  alias Survey.{Parser, State, Question, Answer}

  describe "process/1" do
    setup do
      Application.ensure_all_started(:survey)
      {:ok, questions: "./test/questions_sample.csv", answers: "./test/answers_sample.csv"}
    end

    test "returns error for missing files" do
      assert {:error, _} = Parser.process([])
    end

    test "transitions to processing", %{questions: questions, answers: answers} do
      Parser.process([questions: questions, answers: answers])
      assert State.current == {:start, :processing}
    end

    test "returns parsed data for each file", %{questions: questions, answers: answers} do
      assert {:ok, {[%Question{}, %Question{}, %Question{}, %Question{}, %Question{}],[%Answer{}, %Answer{}, %Answer{}, %Answer{}, %Answer{}, %Answer{}]}} = Parser.process([questions: questions, answers: answers])
    end
  end
end
