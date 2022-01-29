defmodule KvStorageRedis.MixProject do
  use Mix.Project

  def project do
    [
      app: :kv_storage_redis,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:redix, "~> 1.1"},
      {:ex_check, "~> 0.14.0", only: [:dev], runtime: false}
    ]
  end
end
