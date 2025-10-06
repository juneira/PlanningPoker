defmodule PlanningPoker.PlayerManagerTest do
  use ExUnit.Case, async: true
  alias PlanningPoker.PlayerManager
  alias PlanningPoker.Player

  test "creates a new player" do
    {:ok, pid} = PlayerManager.create_player("Alice")
    assert Process.alive?(pid)
    assert {:ok, %PlanningPoker.Entity.Player{name: "Alice"}} = Player.lookup_player(pid)
  end
end
