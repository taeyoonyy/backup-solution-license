defmodule Backsol.MixProject do
  use Mix.Project

  def project do
    [
      app: :backsol,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Backsol.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.5"},
      {:ecto_sql, "~> 3.7"},
      {:postgrex, "~> 0.15.10"},
      {:jason, "~> 1.2"},
      {:joken, "~> 2.4"}
    ]
  end
end
