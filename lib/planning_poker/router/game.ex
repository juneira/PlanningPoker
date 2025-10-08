defmodule PlanningPoker.Router.Game do
  use Plug.Router

  plug(Plug.Logger)
  plug(PlanningPoker.Plug.AuthenticatePlayer)
  plug(:match)
  plug(:dispatch)

  post "/" do
    {:ok, body, _conn} = Plug.Conn.read_body(conn)

    case Jason.decode(body) do
      {:ok, %{"title" => title}} ->
        case PlanningPoker.Controller.Game.create_game(conn.assigns.current_player, title) do
          {:ok, %{game_uuid: game_uuid, title: title}} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(201, Jason.encode!(%{uuid: game_uuid, title: title}))

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
end
