defmodule Survey.ResultsViewerTest do
  use ExUnit.Case, async: false
  import ExUnit.CaptureIO

  setup do
    Application.ensure_all_started(:survey)
    questions = "./test/questions_sample.csv"
    answers = "./test/answers_sample.csv"
    {:ok, {questions, answers}} =
      [questions: questions, answers: answers]
      |> Survey.Parser.process()
    {:ok, questions: questions , answers: answers}
  end

  test "outputs question summary", %{questions: qs, answers: as} do
    assert capture_io(fn -> (Survey.Analyser.process({qs, as}) |> elem(1) |> Survey.ResultsViewer.display_results(qs)) end) =~ "Questions"
  end

  test "outputs summary", %{questions: qs, answers: as} do
    assert capture_io(fn -> (Survey.Analyser.process({qs, as}) |> elem(1) |> Survey.ResultsViewer.display_results(qs)) end) =~ "Summary"
  end

  test "outputs answers", %{questions: qs, answers: as} do
    assert capture_io(fn -> (Survey.Analyser.process({qs, as}) |> elem(1) |> Survey.ResultsViewer.display_results(qs)) end) =~ "Answers"
  end

  test "outputs averages", %{questions: qs, answers: as} do
    assert capture_io(fn -> (Survey.Analyser.process({qs, as}) |> elem(1) |> Survey.ResultsViewer.display_results(qs)) end) =~ "Averages"
  end

end
