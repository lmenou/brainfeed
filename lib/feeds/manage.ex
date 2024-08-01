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

  Queries the database and return the result under the form of a `map` or a
  `list` of `map` to be jsonized.
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
  Update feed information on the database.

  The provided arguments **gives the hint** on **where to update** on the
  database.

  Note that each feed must be unique, hence only one entry will get
  updated if a feed is provided via the map.
  Otherwise, multiple entries can be updated in the case of an author.
  """
  @spec update_on(%{author: String.t()} | %{feed: String.t()}, map()) :: non_neg_integer()
  def update_on(%{author: author}, data) do
    case data do
      %{"author" => to_update_author, "feed" => to_update_feed} ->
        with {updated, _} <-
               from(f in Feeds.Feed,
                 where: f.author == ^author,
                 update: [set: [feed: ^to_update_feed, author: ^to_update_author]]
               )
               |> Feeds.Repo.update_all([]) do
          updated
        end

      %{"author" => to_update} ->
        with {updated, _} <-
               from(f in Feeds.Feed,
                 where: f.author == ^author,
                 update: [set: [author: ^to_update]]
               )
               |> Feeds.Repo.update_all([]) do
          updated
        end

      %{"feed" => to_update} ->
        with {updated, _} <-
               from(f in Feeds.Feed,
                 where: f.author == ^author,
                 update: [set: [feed: ^to_update]]
               )
               |> Feeds.Repo.update_all([]) do
          updated
        end
    end
  end

  def update_on(%{feed: feed}, data) do
    case data do
      %{"author" => to_update_author, "feed" => to_update_feed} ->
        with {updated, _} <-
               from(f in Feeds.Feed,
                 where: f.author == ^feed,
                 update: [set: [feed: ^to_update_feed, author: ^to_update_author]]
               )
               |> Feeds.Repo.update_all([]) do
          updated
        end

      %{"author" => to_update} ->
        with {updated, _} <-
               from(f in Feeds.Feed,
                 where: f.author == ^feed,
                 update: [set: [author: ^to_update]]
               )
               |> Feeds.Repo.update_all([]) do
          updated
        end

      %{"feed" => to_update} ->
        with {updated, _} <-
               from(f in Feeds.Feed,
                 where: f.author == ^feed,
                 update: [set: [feed: ^to_update]]
               )
               |> Feeds.Repo.update_all([]) do
          updated
        end
    end
  end

  @doc """
  Delete an entry to the `feeds` table.

  If `%{feed: feed}` is given, abort cowardly if the entry is not found or not
  unique. Otherwise try to delete all the entries containing the map provided
  `author`.
  """
  @spec delete_on(%{feed: String.t()} | %{author: String.t()}) :: {atom(), map()}
  def delete_on(%{feed: feed}) do
    case Feeds.Repo.get_by(Feeds.Feed, feed: feed) do
      nil ->
        Logger.error("Could not find an entry for #{feed}?")
        {:error, %{message: "Could not find the #{feed} entry, aborting"}}

      to_del ->
        case Feeds.Repo.delete(to_del) do
          {:ok, deleted} ->
            {:ok, Map.from_struct(deleted)}

          {:error, changeset} ->
            Logger.error("Could not delete the entry #{feed}")
            {:error, generate_error_map(changeset)}
        end
    end
  rescue
    _ ->
      Logger.error("Internal error occured while deleting the entry #{feed}")
      {:error, %{message: "Error occured for #{feed} deletion, aborting"}}
  end

  def delete_on(%{author: author}) do
    query =
      from(f in Feeds.Feed,
        where: f.author == ^author
      )

    with {num, _} <- Feeds.Repo.delete_all(query) do
      Logger.info("Deleted #{num} entry with author: #{author}")
      {:ok, %{message: "deleted #{num} entries"}}
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
