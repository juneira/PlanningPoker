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
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(201, Jason.encode!(%{uuid: player.uuid, name: player.name}))

          {:error, reason} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(422, Jason.encode!(%{error: reason}))
        end

      _ ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(422, Jason.encode!(%{error: "Invalid data"}))
    end
  end

  get "/:uuid" do
    case PlanningPoker.Controller.Player.lookup_player(uuid) do
      {:ok, player} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(200, Jason.encode!(%{uuid: player.uuid, name: player.name}))

      {:error, :player_not_found} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(404, Jason.encode!(%{error: "Player not found"}))

      {:error, reason} ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(422, Jason.encode!(%{error: reason}))
    end
  end
end
