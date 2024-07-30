# Brainfeed, a simple RSSfeed server ?
# Copyright (C) 2024  Brainfeed's author(s)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

defmodule Brainfeed.MixProject do
  @moduledoc false

  use Mix.Project

  def project do
    [
      app: :brainfeed,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: extra_applications(Mix.env(), [:logger]),
      mod: {Brainfeed, []}
    ]
  end

  defp extra_applications(:dev, default) do
    default ++ [:lettuce]
  end

  defp extra_applications(_, default) do
    default
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:plug_cowboy, "~> 2.0"},
      {:poison, "~> 5.0"},
      {:ecto_sqlite3, "~> 0.16"},
      {:lettuce, "~> 0.3.0", only: :dev},
      {:credo, "~> 1.7.7", only: [:dev, :test], runtime: false}
    ]
  end
end
