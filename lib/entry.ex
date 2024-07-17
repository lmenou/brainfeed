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

defmodule Entry do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    response = Poison.encode!(%{message: "It works"})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, response)
  end
end
