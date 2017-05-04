defmodule Survey.CLI do
  alias Survey.{State, Parser}
  @valid_args [switches: [questions: :string, answers: :string], aliases: [q: :questions, a: :answers]]

  @moduledoc """
  Entry point for the CLI application.
  """

  @doc """
  Invoked when the application starts
  """
  def main(args) do
    State.transition(:analyse)
    with {a, _, _}       <- OptionParser.parse(args, @valid_args),
         {:ok, data}        <- Parser.process_files(a) do
         #{:ok, results}     <- Parser.analyse_data(data),
         #{:ok, table}       <- ResultsViewer.display_results(results) do
           IO.puts "done"
         else
           {:error, reason} -> IO.puts reason
           _                -> IO.puts "An unexpected error occured processing your files. Please make sure they are valid and then try again"
         end
  end
end
