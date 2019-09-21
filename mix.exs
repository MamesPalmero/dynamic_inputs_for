defmodule DynamicInputsFor.MixProject do
  use Mix.Project

  def project do
    [
      app: :dynamic_inputs_for,
      version: "0.1.0",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "DynamicInputsFor",
      description: "Phoenix view functions to add dynamism to forms with nested fields",
      package: package()
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
      {:phoenix_html, "~> 2.13.3"}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{github: "https://github.com/MamesPalmero/dynamic_inputs_for"},
      files: ~w(lib priv LICENSE mix.exs package.json README.md)
    ]
  end
end
