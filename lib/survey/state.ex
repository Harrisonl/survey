defmodule Survey.State do
  use GenServer

  @moduledoc """
  Used to ensure the user is properly transitioning through
  the application.

  E.g. a valid transition would be from

  :start -> :menu

  but an invalid transition would be from

  :menu -> start

  valid transitions are stored in @valid_transitions in the format of `current_state:  [valid1, valid2]`
  """

  @valid_transitions %{
    :start => [:start, :processing],
    :processing => [:analysing, :start]
  }

  ######### PUBLIC
  
  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end


  ######### GENSERVER IMP

  def init(_) do
    {:ok, {nil, :start}}
  end

  def current() do
    GenServer.call(__MODULE__, {:current})
  end

  def transition(to_state) do
    GenServer.call(__MODULE__, {:transition, to_state})
  end

  def reset() do
    GenServer.call(__MODULE__, {:reset})
  end

  ######### HELPERS
  def handle_call({:current}, _from, state), do: {:reply, state, state}

  def handle_call({:reset}, _from, _state), do: {:reply, :ok, {nil, :start}}

  def handle_call({:transition, to_state}, _from, {_, current} = state) do
    case validate(@valid_transitions[current], to_state) do
      :ok -> {:reply, :ok, {current, to_state}}
      :invalid -> {:reply, :invalid, state}
    end
  end

  defp validate(nil, _), do: :invalid
  defp validate([], _to_state), do: :invalid
  defp validate([to_state | _r], to_state), do: :ok
  defp validate([_valid | rest], to_state), do: validate(rest, to_state)

end
