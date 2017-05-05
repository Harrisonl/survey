defmodule Survey.CLI do
  alias Survey.{State, Parser, Analyser, ResultsViewer, Cache}
  @valid_args [switches: [questions: :string, answers: :string, survey: :string], aliases: [q: :questions, a: :answers, s: :survey]]

  @moduledoc """
  Entry point for the CLI application.
  """

  @doc """
  Invoked when the application starts.

  Depending on the switches passed in the application can take two paths.

  1. If the --questions and --answers is passed in the application processes
  both files and displays the result.

  2. However if there is a --survey or -s switch, the application will load the previous
  results of that survey from the cache and displays those results.
  """
  def main(args) do
    State.transition(:analyse)
    args
    |> parse_args()
    |> start_application()
  end

  # --------- Helpers
  defp parse_args(args) do
    {a, _, _} =
      args
      |> OptionParser.parse(@valid_args)
    a
  end

  defp start_application(args) do
    case Keyword.has_key?(args, :survey) do
      true -> load_results(args[:survey])
      false -> process_survey(args)
    end
    Cache.save()
    State.transition(:complete)
  end

  def load_results(key) do
    {:ok, {questions, _, results}} = key |> Cache.get()
    ResultsViewer.display_results(results, questions)
  end

  defp process_survey(args) do
    with {:ok, {questions, answers} = data} <- Parser.process(args),
                             {:ok, results} <- Analyser.process(data),
                                        :ok <- ResultsViewer.display_results(results, questions) do
                                          {:ok, key}= Cache.add({questions, answers, results})
                                          IO.puts "Survey saved, your key is: #{key}"
    else
      {:error, reason} -> IO.puts reason
      _                -> IO.puts "An unexpected error occured processing your files. Please make sure they are valid and then try again"
    end
  end
end
