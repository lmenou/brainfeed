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
