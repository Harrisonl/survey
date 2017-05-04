defmodule Survey.Parser do
  alias Survey.{SurveyData, State, Question, Answer}

  @moduledoc """
  Used to parse the files and analyse the results.

  See `parse/1` for parsing and `analyse/2` for analyses
  """

  @doc """
  Processes the parsed in question and answer files
  and presents the results for analyses.

  Takes in two files and returns `{:ok, {questions, answers}` for
  a successful processing of the files.

  If there is a problem processing any of the files, `parse/1` will
  return {:error, message}
  """
  def process_files([questions: q_file, answers: a_file]) do
    State.transition(:processing)

    [{q_file, true}, {a_file, false}]
    |> Enum.map(&(parse_file/1))
    |> parse_data()
  end

  def process_files([questions: f]) when f != nil, do: {:error, "Missing answers file"}
  def process_files([answers: f]) when f != nil, do: {:error, "Missing questions file"}
  def process_files(_), do: {:error, "Missing valid questions and answers file"}

  # ---------- PRIVATE HELPERS
  defp parse_file({file, headers}) do
    file
    |> File.stream!
    |> CSV.decode(headers: headers)
    |> Enum.to_list
  end

  defp parse_data([qs, as]) do
    questions = 
      qs
      |> Enum.with_index(1)
      |> Enum.map(&(parse_question/1))
 
    answers = 
      as
      |> Enum.map(&(parse_answer/1))

    case [questions, answers] do
      [:error, _] -> {:error, "Invalid data in questions files"}
      [_, :error] -> {:error, "Invalid data in answers files"}
      _           -> {:ok, {questions, answers}}
    end
  end

  defp parse_answer({:error, _}), do: :error
  defp parse_answer({:ok, [email, id, timestamp | answers]}) do
    %Answer{email: email, id: id, submitted_at: timestamp, answers: answers}
  end

  defp parse_question({{:error, _}}), do: :error
  defp parse_question({{:ok, %{ "type" => type, "text" => text, "theme" => theme }}, q_num}) do
    %Question{type: type, theme: theme, text: text, number: q_num}
  end
end

