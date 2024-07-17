import Config

config :brainfeed, Feeds.Repo, database: "brainfeed.db"
config :brainfeed, ecto_repos: [Feeds.Repo]
