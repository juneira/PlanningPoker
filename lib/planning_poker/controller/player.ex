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

  def lookup_player(uuid) do
    case get_player_pid(uuid) do
      {:ok, pid} ->
        case PlanningPoker.Player.lookup_player(pid) do
          {:ok, player} ->
            {:ok, player}

          {:error, reason} ->
            {:error, reason}
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def get_player_pid(uuid) do
    case Registry.lookup(PlanningPoker.PlayerRegistry, uuid) do
      [{pid, _value}] ->
        {:ok, pid}

      [] ->
        {:error, :player_not_found}
    end
  end
end
