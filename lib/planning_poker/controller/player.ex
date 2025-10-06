defmodule PlanningPoker.Controller.Player do
  alias PlanningPoker.PlayerManager
  alias PlanningPoker.Player

  def create_player(name) do
    PlayerManager.create_player(name)
    |> case do
      {:ok, pid} ->
        Player.lookup_player(pid)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
