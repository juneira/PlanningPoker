defmodule PlanningPoker.Router do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  forward("/api/players", to: PlanningPoker.Router.Player)

  match _ do
    send_resp(conn, 404, Jason.encode!(%{error: "Not found"}))
  end
end
