defmodule Feeds.Repo.Migrations.CreateFeeds do
  use Ecto.Migration

  def change do
    create table(:feeds) do
      add :feed, :string
      add :author, :string
    end

    create unique_index(:feeds, [:feed])
  end
end
