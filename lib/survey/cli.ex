defmodule Survey.CLI do
  alias Survey.{State, Parser, Analyse, ResultsViewer}
  @valid_args [switches: [questions: :string, answers: :string], aliases: [q: :questions, a: :answers]]

  @moduledoc """
  Entry point for the CLI application.
  """

  @doc """
  Invoked when the application starts
  """
  def main(args) do
    State.transition(:analyse)
    with {a, _, _}                          <- OptionParser.parse(args, @valid_args),
         {:ok, {questions, answers} = data} <- Parser.process(a),
         {:ok, results}                     <- Analyse.process(data),
         :ok                       <- ResultsViewer.display_results(results, questions) do
           IO.puts "done"
         else
           {:error, reason} -> IO.puts reason
           _                -> IO.puts "An unexpected error occured processing your files. Please make sure they are valid and then try again"
         end
  end
end
