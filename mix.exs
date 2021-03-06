defmodule Survey.Mixfile do
  use Mix.Project

  def project do
    [app: :survey,
     version: "0.1.0",
     elixir: "~> 1.4",
     escript: [main_module: Survey.CLI],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [extra_applications: [:logger],
     mod: {Survey.Application, []}]
  end

  defp deps do
    [
      {:csv, github: "harrisonl/csv"},
      {:table_rex, "~> 0.10"}
    ]

  end
end
