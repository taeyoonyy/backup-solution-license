defmodule Backsol.Application do
  use Application

  @impl true
  def start(_type, _args) do
    port = start_web_server()
    children = [
      {Plug.Cowboy, scheme: :http, plug: Backsol.Router, port: port},
      %{
        id: Backsol.AccountServer,
        start: {Backsol.AccountServer, :start_link, []}
      },
      Backsol.Repo
    ]
    opts = [strategy: :one_for_one, name: Backsol.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp start_web_server() do
    Application.get_env(:plug_ex, :cowboy_port, 33399)
  end
end
