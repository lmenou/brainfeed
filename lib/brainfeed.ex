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

defmodule Brainfeed do
  @moduledoc """
  `Brainfeed`, a simple server to feed your brain.
  """

  require Logger
  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Entry, port: 4040},
      Feeds.Repo
    ]

    opts = [strategy: :one_for_one, name: __MODULE__.Supervisor]
    Logger.info("Running on localhost:4040")
    Supervisor.start_link(children, opts)
  end
end
