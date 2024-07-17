defmodule Feeds.Repo do
  use Ecto.Repo,
    otp_app: :brainfeed,
    adapter: Ecto.Adapters.SQLite3
end
