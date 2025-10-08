defmodule PlanningPoker.Plug.AuthenticatePlayer do
  import Plug.Conn
  alias PlanningPoker.Controller.Player

  def init(opts), do: opts

  def call(conn, _opts) do
    case get_req_header(conn, "x-api-key") do
      [uuid] ->
        case Player.get_player_pid(uuid) do
          {:ok, player} ->
            assign(conn, :current_player, player)

          {:error, :player_not_found} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(401, Jason.encode!(%{error: "Invalid or missing player token"}))
            |> halt()

          {:error, _reason} ->
            conn
            |> put_resp_content_type("application/json")
            |> send_resp(401, Jason.encode!(%{error: "Authentication failed"}))
            |> halt()
        end

      [] ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(401, Jason.encode!(%{error: "Missing x-api header"}))
        |> halt()
    end
  end
end
