defmodule WebServer.MixProject do
  use Mix.Project

  def project do
    [
      app: :web_server,
      version: "0.1.0-dev",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {WebServer, []},
      extra_applications: [:logger, :storage]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:storage, in_umbrella: true},
      {:distillery, "~> 2.0"},
      {:plug_cowboy, "~> 2.0"}
    ]
  end
end
