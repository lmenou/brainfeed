import Config

config :brainfeed, Feeds.Repo, database: "brainfeed.db"
config :brainfeed, ecto_repos: [Feeds.Repo]
config :lettuce, folders_to_watch: ["lib", "priv", "config"]

config :logger,
  backends: [:console],
  console: [
    format: "[$level] $message\n",
    metadata: [:request_id]
  ],
  level: :info
