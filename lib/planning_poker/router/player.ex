defmodule PlanningPoker.Router.Player do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  post "/" do
    {:ok, body, _conn} = Plug.Conn.read_body(conn)

    case Jason.decode(body) do
      {:ok, %{"name" => name}} ->
        case PlanningPoker.Controller.Player.create_player(name) do
          {:ok, player} ->
            send_resp(conn, 201, Jason.encode!(%{uuid: player.uuid, name: player.name}))

          {:error, reason} ->
            send_resp(conn, 422, Jason.encode!(%{error: reason}))
        end

      _ ->
        send_resp(conn, 422, Jason.encode!(%{error: "Invalid data"}))
    end
  end

  get "/:uuid" do
    case PlanningPoker.Controller.Player.lookup_player(uuid) do
      {:ok, player} ->
        send_resp(conn, 200, Jason.encode!(%{uuid: player.uuid, name: player.name}))

      {:error, :player_not_found} ->
        send_resp(conn, 404, Jason.encode!(%{error: "Player not found"}))

      {:error, reason} ->
        send_resp(conn, 422, Jason.encode!(%{error: reason}))
    end
  end
end
