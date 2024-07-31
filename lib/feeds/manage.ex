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
  import Ecto.Query, only: [from: 2]

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
  Find an element in the `feeds` table.

  Queries the database and return the result under the form of a `Map` or a
  `List` of `Map` to be jsonized.
  """
  @spec find(%{feed: String.t()} | %{author: String.t()}) ::
          :not_found | {:ok, map() | list(map())} | {:error, map()}
  def find(%{feed: feed}) do
    result = Feeds.Feed |> Feeds.Repo.get_by(feed: feed)

    case result do
      nil -> :not_found
      feed -> {:ok, feed |> Map.from_struct() |> Map.delete(:__meta__)}
    end
  rescue
    e ->
      Logger.error("Found more than one entry for #{feed}", inspect(e))
      {:error, %{:message => "more than one entry for #{feed}"}}
  end

  def find(%{author: author}) do
    query =
      from(feed in "feeds", where: feed.author == ^author, select: {feed.feed, feed.author})

    result = Feeds.Repo.all(query)

    case result do
      [] ->
        :not_found

      [_ | _] ->
        {:ok,
         Enum.map(result, fn item -> %{:feed => elem(item, 0), :author => elem(item, 1)} end)}
    end
  end

  @doc """
  Delete an entry to the `feeds` table.

  Must be passed a `String.t()` containing the feed address.
  Abort cowardly if the entry is not found or not unique.
  """
  @spec delete(String.t()) :: {term(), map()}
  def delete(feed) do
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
