import Config

config :logger,
  backends: [:console],
  console: [
    format: "[$level] $message\n",
    metadata: [:request_id]
  ],
  level: :debug
