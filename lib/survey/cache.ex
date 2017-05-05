defmodule Survey.Cache do
  use GenServer

  @table :cache

  @moduledoc """
  Cache for storing past survey's for easy retrieval.

  * Adding Surveys see `add/1`
  * Retrieving Surveys see `get/1`
  * Persisting the cache see `save/0`
  """

  # ---------------- Public API
  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  @doc """
  Takes in all survey data and stores it in the cache.

  Stores it under a pseudo-randomly generated key.
  ```
  iex>Cache.add({[%Question{}], [%Answer{}], %Results{}})
  {:ok, "asd23fd23"}
  ```
  """
  def add({questions, answers, results} = payload) do
    GenServer.call(__MODULE__, {:add, payload})
  end

  @doc """
  Takes in a key and returns the survey data stored at that
  key:

  ```
  iex>Cache.get("asrfew23dc")
  [{"asrfew23dc", {..}}]
  ```
  """
  def get(key) do
    GenServer.call(__MODULE__, {:get, key})
  end

  @doc """
  Saves the current ets table into a file, so that it can
  be reloaded in the future.
  """
  def save() do
    GenServer.call(__MODULE__, {:save})
  end

  def delete_all() do
    GenServer.call(__MODULE__, {:delete_all})
  end

  # ---------------- GenServer Implementation
  def init(_) do
    initialize_table()
    {:ok, nil}
  end

  def handle_call({:add, payload}, _from, state) do
    key = :crypto.hash(:sha, (:rand.uniform() |> to_string)) |> Base.encode64
    :ets.insert(@table, {key, payload})
    {:reply, {:ok, key}, state}
  end

  def handle_call({:get, key}, _from, state) do
    val =
      @table
      |> :ets.lookup(key)
      |> Keyword.values()
      |> List.first()

    {:reply, {:ok, val}, state}
  end

  def handle_call({:save}, _from, state) do
    :ets.tab2file(@table, 'dump.ets')
    {:reply, :ok, state}
  end

  def handle_call({:delete_all}, _from, state) do
    :ets.delete_all_objects(@table)
    {:reply, :ok, state}
  end

  # ---------------- Private Helpers
  defp initialize_table() do
    "dump.ets"
    |> File.exists?
    |> start_table()
  end

  defp start_table(true), do: :ets.file2tab('dump.ets')
  defp start_table(_), do: :ets.new(@table, [:named_table])
end
