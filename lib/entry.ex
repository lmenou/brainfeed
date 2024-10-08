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
    Logger.debug("Got root request!")

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, encoded)
  end

  post "/add" do
    fetch_query_params(conn)
    params = conn.query_params()

    case {params[~s"feed"], params[~s"author"]} do
      {nil, _} ->
        make_response(conn, 400, %{:message => "Could not process the request"})

      {_, nil} ->
        make_response(conn, 400, %{:message => "Could not process the request"})

      {_, _} ->
        to_add = %{author: params[~s"author"], feed: params[~s"feed"]}

        case Feeds.Manage.add(to_add) do
          {:ok, feed} ->
            Logger.info("Adding feed #{params[~s"feed"]} to the database")
            make_response(conn, 200, feed)

          {:error, error} ->
            Logger.error("Problem occured while adding feed #{params[~s"feed"]} to the database")
            make_response(conn, 400, error)
        end
    end
  end

  get "/find" do
    fetch_query_params(conn)
    params = conn.query_params()

    case {params[~s"feed"], params[~s"author"]} do
      {nil, nil} ->
        make_response(conn, 400, %{:message => "Could not process request"})

      {nil, author} ->
        case Feeds.Manage.find(%{author: author}) do
          :not_found ->
            make_response(conn, 404)

          {:ok, result} ->
            make_response(conn, 200, result)
        end

      {feed, _} ->
        case Feeds.Manage.find(%{feed: feed}) do
          :not_found -> make_response(conn, 404)
          {:ok, feed} -> make_response(conn, 200, feed)
          {:error, message} -> make_response(conn, 400, message)
        end
    end
  end

  put "/update" do
    fetch_query_params(conn)
    params = conn.query_params()

    case {params[~s"feed"], params[~s"author"]} do
      {nil, nil} ->
        make_response(conn, 400, %{:message => "Could not process request"})

      {nil, author} ->
        Logger.warning("Attempt to update on records with author: #{author}")

        with {:ok, response} <- Feeds.Manage.update_on(%{author: author}, conn.body_params()) do
          Logger.info("Update on #{params[~s"author"]} occured")
          make_response(conn, 200, response)
        end

      {feed, _} ->
        Logger.warning("Attempt to update on records with author: #{feed}")

        with {:ok, response} <- Feeds.Manage.update_on(%{feed: feed}, conn.body_params()) do
          Logger.info("Update on #{params[~s"author"]} occured")
          make_response(conn, 200, response)
        end
    end
  end

  post "/delete" do
    fetch_query_params(conn)
    params = conn.query_params()

    case {params[~s"feed"], params[~s"author"]} do
      {nil, nil} ->
        make_response(conn, 400, %{:message => "Could not process request"})

      {nil, author} ->
        Logger.warning("Attempt to delete on records with author: #{author}")

        with {:ok, response} <- Feeds.Manage.delete_on(%{author: author}) do
          Logger.info("Deletion of #{params[~s"author"]} occured")
          make_response(conn, 200, response)
        end

      {feed, _} ->
        case Feeds.Manage.delete_on(%{feed: feed}) do
          {:ok, feed} ->
            Logger.info("Deletion of #{params[~s"feed"]} occured")
            make_response(conn, 200, feed)

          {:error, error} ->
            Logger.error("Could not delete with #{params[~s"feed"]}")
            make_response(conn, 400, error)
        end
    end
  end

  match _ do
    Logger.debug("A non-defined route was called!")
    {:ok, encoded} = Poison.encode(%{message: "Route not found"})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(404, encoded)
  end

  @spec make_response(Plug.Conn.t(), Plug.Conn.status(), map() | nil) :: Plug.Conn.t()
  defp make_response(conn, status_code, to_jsonize) do
    # simply return the appropriate encoded response
    {:ok, message} = Poison.encode(to_jsonize)

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(status_code, message)
  end

  defp make_response(conn, status_code) do
    send_resp(conn, status_code, "")
  end
end
