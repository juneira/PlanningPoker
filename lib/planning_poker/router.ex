defmodule PlanningPoker.Router do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  forward("/api/players", to: PlanningPoker.Router.Player)
  forward("/api/games", to: PlanningPoker.Router.Game)

  match _ do
    send_resp(conn, 404, Jason.encode!(%{error: "Not found"}))
  end
end
