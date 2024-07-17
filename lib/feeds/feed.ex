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
  import Ecto.Changeset

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

  defp generate_error_map(changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
