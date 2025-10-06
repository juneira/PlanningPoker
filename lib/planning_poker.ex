defmodule PlanningPoker do
  use Application

  def start(_type, _args) do
    children = [
      {Registry, keys: :unique, name: PlanningPoker.GameRegistry},
      {Registry, keys: :unique, name: PlanningPoker.PlayerRegistry},
      PlanningPoker.PlayerManager,
      {Plug.Cowboy, scheme: :http, plug: PlanningPoker.Router, options: [port: 4001]}
    ]

    opts = [strategy: :one_for_one, name: PlanningPoker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
