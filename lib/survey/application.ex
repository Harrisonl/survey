defmodule Survey.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Survey.State, [])
    ]

    opts = [strategy: :one_for_one, name: Survey.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
