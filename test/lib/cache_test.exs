defmodule Survey.CacheTest do
  use ExUnit.Case, async: false
  alias Survey.{Parser, Analyser, Cache}

  setup do
    Application.ensure_all_started(:survey)
    on_exit fn ->
      File.rm("dump.ets")
    end
    cond do
      Process.whereis(Cache) -> Cache.delete_all()
      true -> nil
    end
    questions = "./test/questions_sample.csv"
    answers = "./test/answers_sample.csv"
    {:ok, {questions, answers}} =
      [questions: questions, answers: answers]
      |> Parser.process()
    {:ok, results} = Analyser.process({questions, answers})
    {:ok, questions: questions , answers: answers, results: results}
  end

  test "returns the key when inserting into the cache", %{questions: qs, answers: as, results: rs} do
    assert {:ok, _} = Cache.add({qs, as, rs})
  end

  test "returns the survey when retrieving from the cache", %{questions: qs, answers: as, results: rs} do
    {:ok, key} = Cache.add({qs, as, rs})
    assert {:ok, {qs, as, rs}} == Cache.get(key)
  end

  test "saves the table to file" do
    refute File.exists?("dump.ets")
    Cache.save()
    assert File.exists?("dump.ets")
  end

  test "loads the table from file if it exists", %{questions: qs, answers: as, results: rs} do
    {:ok, key} = Cache.add({qs, as, rs})
    Cache.save()
    Process.whereis(Cache) |> GenServer.stop()
    Cache.start_link()
    assert {:ok, {qs, as, rs}} == Cache.get(key)
  end
end
