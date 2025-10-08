defmodule PlanningPoker.Controller.Game do
  alias PlanningPoker.Player

  def create_game(player_server, title) do
    case Player.create_game(player_server, title) do
      {:ok, game_uuid} ->
        {:ok, %{game_uuid: game_uuid, title: title}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
