defmodule Survey.StateTest do
  use TestHelper
  alias Survey.State

  test "initial state should be :start" do
    assert State.current() == {nil, :start}
  end

  test "should store the previous and current" do
    State.transition(:processing)
    assert State.current() == {:start, :processing}
  end

  test "should change state for a valid transition" do
    State.transition(:processing)
    assert State.current() == {:start, :processing}
  end

  test "should return :invalid for an invalid transition" do
    assert State.transition(:foo) == :invalid
    assert State.current() == {nil, :start}
  end
end
