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
  @moduledoc """
  Define the main routes of the Brainfeed App.
  """

  use Plug.Router
  import Plug.Conn
  require Logger

  plug(:match)

  plug(Plug.Parsers,
    parsers: [:json],
    pass: ["application/json"],
    json_decoder: Poison
  )

  plug(:dispatch)

  get "/" do
    {:ok, encoded} = Poison.encode(%{message: "Brainfeed at your service!"})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, encoded)
  end

  post "/add" do
    fetch_query_params(conn)
    params = conn.query_params()
    to_add = %{author: params[~s"author"], feed: params[~s"feed"]}

    case Feeds.Manage.add(to_add) do
      {:ok, feed} ->
        Logger.info("Adding feed #{params[~s"feed"]} to the database")
        make_response(200, feed, conn)

      {:error, error} ->
        Logger.error("Problem occured while adding feed #{params[~s"feed"]} to the database")
        make_response(400, error, conn)
    end
  end

  post "/delete" do
    fetch_query_params(conn)
    params = conn.query_params()
    to_delete = params[~s"feed"]
    Logger.warning("Attempt to delete #{params[~s"feed"]}")

    case Feeds.Manage.delete(to_delete) do
      {:ok, feed} ->
        Logger.info("Deletion of #{params[~s"feed"]} occured")
        make_response(200, feed, conn)

      {:error, error} ->
        Logger.error("Could not delete #{params[~s"feed"]}")
        make_response(400, error, conn)
    end
  end

  match _ do
    {:ok, encoded} = Poison.encode(%{message: "Not found"})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, encoded)
  end

  @spec make_response(integer(), map(), Plug.Conn.t()) :: Plug.Conn.t()
  # simply return the appropriate encoded response
  defp make_response(status_code, to_jsonize, conn) do
    {:ok, message} = Poison.encode(to_jsonize)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code, message)
  end
end
