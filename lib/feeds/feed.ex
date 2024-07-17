defmodule Feeds.Feed do
  use Ecto.Schema
  import Ecto.Changeset

  schema "feeds" do
    field(:feed, :string)
    field(:author, :string)
  end

  def changeset(feed, params \\ %{}) do
    feed
    |> cast(params, [:author, :feed])
    |> validate_required([:feed])
    |> unique_constraint([:feed])
  end
end

defmodule Feeds.Manage do
  def add(request_content) do
    params = %{
      author: Map.get(request_content, ~s"author"),
      feed: Map.get(request_content, ~s"feed")
    }

    %Feeds.Feed{}
    |> Feeds.Feed.changeset(params)
    |> Feeds.Repo.insert()
    |> case do
      {:ok, _} -> true
      {:error, _changeset} -> false
    end
  end
end
