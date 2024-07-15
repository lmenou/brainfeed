defmodule Brainfeed do
  @moduledoc """
  `Brainfeed`, a simple server to feed your brain.
  """

  require Logger
  use Application

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: Entry, port: 4040}
    ]

    opts = [strategy: :one_for_one, name: __MODULE__.Supervisor]
    Logger.info("Running on localhost:4040")
    Supervisor.start_link(children, opts)
  end
end
