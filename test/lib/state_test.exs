defmodule Survey.StateTest do
  use ExUnit.Case
  alias Survey.State

  setup do
    State.reset()
  end

  test "initial state should be :start" do
    assert State.current() == {nil, :start}
  end

  test "should store the previous and current" do
    State.transition(:analyse)
    assert State.current() == {:start, :analyse}
  end

  test "should change state for a valid transition" do
    State.transition(:analyse)
    assert State.current() == {:start, :analyse}
  end

  test "should return :invalid for an invalid transition" do
    assert State.transition(:foo) == :invalid
    assert State.current() == {nil, :start}
  end
end
