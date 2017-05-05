defmodule Survey.AnalyseTest do
  use ExUnit.Case

  setup do
    questions = "./test/questions_sample.csv"
    answers = "./test/answers_sample.csv"
    {:ok, {questions, answers}} =
      [questions: questions, answers: answers]
      |> Survey.Parser.process()
    {:ok, questions: questions , answers: answers}
  end

  test "returns a results struct", %{questions: qs, answers: as} do
    assert Survey.Analyse.process({qs, as}) == 
      {:ok, %Survey.Results{
        averages: %{1 => 4.6, 2 => 5.0, 3 => 5.0, 4 => 3.6, 5 => 3.6},
         participated: 5, 
         percentage: 83.33333333333334,
         questions: %{1 => [{"4", "5"}, {"5", "4"}, {"5", "3"}, {"4", "2"}, {"5", "1"}],
           2 => [{"5", "5"}, {"5", "4"}, {"5", "3"}, {"5", "2"}, {"5", "1"}],
           3 => [{"5", "5"}, {"5", "4"}, {"5", "3"}, {"5", "2"}, {"5", "1"}],
           4 => [{"2", "5"}, {"4", "4"}, {"5", "3"}, {"3", "2"}, {"4", "1"}],
           5 => [{"3", "5"}, {"4", "4"}, {"4", "3"}, {"3", "2"}, {"4", "1"}]}
      }}
  end
end

