defmodule Survey.StateTest do
  use ExUnit.Case
  alias Survey.State

  setup do
    State.reset()
  end

  test "initial state should be :start" do
    assert State.current() == :start
  end

  test "should change state for a valid transition" do
    State.transition(:menu)

    assert State.current() == :menu
  end

  test "should return :invalid for an invalid transition" do
    assert State.transition(:foo) == :invalid
    assert State.current() == :start
  end
end
