import Config

config :brainfeed, Feeds.Repo, database: "brainfeed.db"
config :brainfeed, ecto_repos: [Feeds.Repo]
config :lettuce, folders_to_watch: ["lib", "priv", "config"]

if config_env() == :dev do
  config :logger, :default_handler, level: :debug
  config :logger, :default_formatter, format: "$message $metadata"
else
  config :logger, :default_handler, level: :info
  config :logger, :default_formatter, format: "$time $message $metadata"
end
