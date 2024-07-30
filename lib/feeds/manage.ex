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

defmodule Feeds.Manage do
  @moduledoc """
  Define API to use the database.
  """
  require Logger
  import Ecto.Changeset

  @doc """
  Add an entry to the `feeds` table.

  Must be passed a map resulting from the parsing of a `json`.
  The `json` as of now, must satisfy the `Feeds.Feed` schema.
  Here is an example of such a `json`: `{ "author": "me", "feed": "http://my-awesome-feed.fr" }`
  """
  @spec add(map()) :: {term(), map()}
  def add(params) do
    %Feeds.Feed{}
    |> Feeds.Feed.changeset(params)
    |> Feeds.Repo.insert()
    |> case do
      {:ok, feed} -> {:ok, Map.from_struct(feed)}
      {:error, changeset} -> {:error, generate_error_map(changeset)}
    end
  end

  @doc """
  Get an entry to the `feeds` table.
  """
  def get(request_content) do
    IO.inspect(request_content)
  end

  @doc """
  Delete an entry to the `feeds` table.

  Must be passed a `String.t()` containing the feed address.
  Abort cowardly if the entry is not found or not unique.
  """
  @spec delete(String.t()) :: {term(), map()}
  def delete(feed) do
    try do
      result = Feeds.Feed |> Feeds.Repo.get_by(feed: feed)

      case result do
        {:ok, feed} ->
          deletion = Feeds.Repo.delete(feed)

          case deletion do
            {:ok, feed} ->
              {:ok, Map.from_struct(feed)}

            {:error, changeset} ->
              {:error, generate_error_map(changeset)}
          end

        nil ->
          Logger.error("Could not find an entry for #{feed}?")
          {:error, %{message: "Could not find the #{feed} entry, aborting"}}
      end
    rescue
      e ->
        Logger.error("Could be more than one entry", inspect(e))
        {:error, %{message: "Possibly more than one entry for #{feed}, aborting"}}
    end
  end

  @spec generate_error_map(map()) :: map()
  # Generate a map from an error on Ecto insertion.
  defp generate_error_map(changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
