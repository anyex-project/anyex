defmodule WebServer.MixProject do
  use Mix.Project

  @version "0.10.4-dev"

  def project do
    [
      app: :web_server,
      version: @version,
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def get_roor_version do
    Mix.Project.get().project[:version]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {WebServer, []},
      extra_applications: [:logger, :storage, :plug_cowboy]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:storage, in_umbrella: true},
      {:distillery, "~> 2.0"},
      {:plug_cowboy, "~> 2.0"},
      {:jason, "~> 1.1"},
      {:joken, "~> 2.0"},
      {:atomic_map, "~> 0.9.3"},
      {:earmark, "~> 1.3"},
      {:cors_plug, "~> 2.0"},
      {:elixir_uuid, "~> 1.2"}
    ]
  end
end
