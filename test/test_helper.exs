ExUnit.start()
Application.ensure_all_started(:survey)

defmodule TestHelper do
  
  defmacro __using__(_opts) do
    quote do
      use ExUnit.Case, async: false

      setup do
        Application.ensure_all_started(:survey)
        case Process.whereis(Survey.State) do
          nil -> nil
          _pid -> Survey.State.reset()
        end
        :ok
      end
    end
  end
end
