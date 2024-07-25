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

defmodule Feeds.Feed do
  @moduledoc """
  Define the Feed Schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "feeds" do
    field(:feed, :string)
    field(:author, :string)
  end

  @doc """
  Enforce some constraints on Feed change.
  """
  @spec changeset(Ecto.Schema.t(), map()) :: Echo.Changeset.t()
  def changeset(feed, params \\ %{}) do
    feed
    |> cast(params, [:author, :feed])
    |> validate_required([:feed])
    |> unique_constraint([:feed])
  end
end

defmodule Feeds.Manage do
  @moduledoc """
  Define API to use the database.
  """
  import Ecto.Changeset

  @doc """
  Add an entry to the `feeds` table.

  Must be passed a map resulting from the parsing of a `json`.
  The `json` as of now, must satisfy the `Feeds.Feed` schema.
  Here is an example of such a `json`: `{ "author": "me", "feed": "http://my-awesome-feed.fr" }`
  """
  @spec add(map()) :: {term(), map()}
  def add(request_content) do
    params = %{
      author: Map.get(request_content, ~s"author"),
      feed: Map.get(request_content, ~s"feed")
    }

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
