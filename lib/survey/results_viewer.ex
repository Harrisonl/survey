defmodule Survey.ResultsViewer do
  alias Survey.Results
  @moduledoc """
  Used to format and display the results.

  See `display_results/1` for more information.
  """

  @doc """
  Takes in a `%Result{}` struct and returns summary of the information in table format.

  Uses TableRex to output the results nicely.
  """
  def display_results(results, questions) do
    display_questions(questions)
    display_summary(results)
    display_answers(results)
    display_averages(results)
  end

  # ------------ PRIVATE
  defp display_questions(questions) do
    render(question_summary(questions), ["Number", "Type", "Text"], "Questions")
  end

  defp display_summary(results) do
    render(summary(results), [], "Summary")
  end

  defp display_answers(results) do
    case answers(results) |> List.flatten do
      [] -> render([["No Valid Answers"]],[] , "Answers")
      _ -> render(answers(results), ["No."] ++ answer_headers(results) , "Answers")
    end
  end

  defp display_averages(results) do
    case averages(results) |> List.flatten do
      [] -> render([["No Valid Answers"]],[] , "Averages")
      _ -> render(averages(results), ["No.", "Average"], "Averages")
    end
  end

  defp summary(results) do
    [
      ["Number of Questions", Map.keys(results.questions) |> length ],
      ["Participated", results.participated], 
      ["Percent", results.percentage ]
    ]
  end

  defp question_summary(questions) do
    questions
    |> Enum.map(fn(q) ->
      [q.number, q.type, q.text]
    end)
  end

  defp answers(results) do
    results.questions
    |> Enum.map(fn({n, answers}) ->
      answers = Enum.map(answers, fn({v, _uid}) ->
        v
      end)

      case answers do
        [] -> []
        _ -> [n] ++ answers
      end
    end)
  end

  defp averages(%Results{averages: 0}), do: []
  defp averages(results) do
    results.averages
    |> Enum.map(fn({n,average}) ->
      [n, average]
    end)
  end

  defp answer_headers(results) do
    results.questions
    |> Enum.map(fn({_n, as}) ->
      Enum.map(as, fn({_v, u_id}) -> "User ID: #{u_id}" end)
    end)
    |> List.first
  end

  defp render(rows, headers, title) do
    TableRex.quick_render!(rows, headers, title)
    |> IO.puts
  end
  
end
