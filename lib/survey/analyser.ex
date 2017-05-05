defmodule Survey.Analyser do
  alias Survey.{Question, Answer, Results, State}

  @moduledoc """
  Handles the analysis of the data. 

  See `process/1` for more information.
  """

  @doc """
  Takes in a two-element tuple with the first element
  being a list of `%Question{}` elements and the second element
  being a list of `%Answer{}` elements.

  Returns a `%Results{}` struct which is typically consumed by
  the `ResultsViewer` module.

  ```elixir
  iex> Analyse.process({[%Question{}..], [%Answer{}..]})
    %Survey.Results{averages: %{1 => 4.6, 2 => 5.0, 3 => 5.0, 4 => 3.6, 5 => 3.6},
     participated: 6, percentage: 83.33333333333334,
     questions: %{1 => [{"4", "5"}, {"5", "4"}, {"5", "3"}, {"4", "2"}, {"5", "1"}],
       2 => [{"5", "5"}, {"5", "4"}, {"5", "3"}, {"5", "2"}, {"5", "1"}],
       3 => [{"5", "5"}, {"5", "4"}, {"5", "3"}, {"5", "2"}, {"5", "1"}],
       4 => [{"2", "5"}, {"4", "4"}, {"5", "3"}, {"3", "2"}, {"4", "1"}],
       5 => [{"3", "5"}, {"4", "4"}, {"4", "3"}, {"3", "2"}, {"4", "1"}]}}
  ```
  """
  def process({questions, answers}) do
    State.transition(:analysing)
    res = %Results{}
    |> add_questions(questions)
    |> add_averages(questions)
    |> add_answers(answers)
    |> calculate_averages()
    |> calculate_participation(answers)

    {:ok, res}
  end

  # ------------ PRIVATE

  def add_questions(results, questions) do
    questions
    |> Enum.reduce(results, fn(q, res) ->
      %{res | questions: Map.put(res.questions, q.number, [])}
    end)
  end

  def add_averages(results, questions) do
    questions
    |> Enum.reduce(results, fn(q, res) ->
      case q.type do
        "ratingquestion" -> %{res | averages: Map.put(res.averages, q.number, 0)}
        _ -> res
      end
    end)
  end

  def add_answers(results, answers) do
    answers
    |> Stream.reject(&(&1.submitted_at == "" || &1.submitted_at == nil))
    |> Stream.map(&({&1.answers, &1.id}))
    |> Enum.reduce(results, fn({answers, u_id}, res) ->
      q_answers = 
        answers
        |> Enum.with_index(1) 
        |> Enum.reduce(res.questions, fn({val, q_num}, q_answers) ->
          %{q_answers | q_num => [{val, u_id} | q_answers[q_num]]}
        end)
      %{res | questions: q_answers}
    end)
  end

  defp calculate_averages(results) do
    averages = 
      results.averages
      |> Enum.reduce(results.averages, fn({num, _}, res) ->
        calc_average(num, results.questions[num], res)
      end)
    %{results | averages: averages}
  end

  def calculate_participation(results, answers) do
    {count, total} = 
      answers
      |> Enum.reduce({0,0}, fn(a, {count, total}) -> 
        case a.submitted_at do
          nil -> {count, total + 1}
          "" -> {count, total + 1}
          _ -> {count + 1, total + 1}
        end
      end)

    results = %{results | participated: count}
    case total do
      0 -> 
        %{results | percentage: 0}
      _ ->
        %{results | percentage: (count / total) * 100}
    end
  end

  def calc_average(q_num, answers, map) do
    {total, count} =
      Enum.reduce(answers, {0,0}, fn({a, _}, {total, count}) ->
        case a do
          "" -> {total, count}
          num -> {total + String.to_integer(num), count + 1}
        end
      end)
    case total do
      0 -> 0
      _ -> Map.put(map, q_num, total / count)
    end
  end
end
