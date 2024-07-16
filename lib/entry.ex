defmodule Entry do
  import Plug.Conn

  def init(options) do
    options
  end

  def call(conn, _opts) do
    response = Poison.encode!(%{message: "It works"})

    conn
    |> put_resp_content_type("application/json")
    |> send_resp(200, response)
  end
end
