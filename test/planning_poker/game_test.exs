defmodule PlanningPoker.GameTest do
  use ExUnit.Case, async: true

  setup do
    owner = %PlanningPoker.Entity.Player{uuid: "owner_uuid", name: "Owner"}
    title = "Game Title"

    game =
      start_supervised!({PlanningPoker.Game, [uuid: UUID.uuid4(), owner: owner, title: title]})

    %{game: game}
  end

  test "creates rounds and looks them up", %{game: game} do
    assert {:ok, round_uuid_1} = PlanningPoker.Game.create_round(game, "Task 1")
    assert {:ok, round_uuid_2} = PlanningPoker.Game.create_round(game, "Task 2")
    assert {:ok, round_uuid_3} = PlanningPoker.Game.create_round(game, "Task 3")
    assert {:error, :invalid_task_description} = PlanningPoker.Game.create_round(game, nil)
    assert {:error, :invalid_task_description} = PlanningPoker.Game.create_round(game, "")

    assert {:ok, pid_1} = PlanningPoker.Game.lookup_round(game, round_uuid_1)
    assert {:ok, pid_2} = PlanningPoker.Game.lookup_round(game, round_uuid_2)
    assert {:ok, pid_3} = PlanningPoker.Game.lookup_round(game, round_uuid_3)
    assert PlanningPoker.Game.lookup_round(game, "invalid_uuid") == {:error, :not_found}

    assert PlanningPoker.Round.show_round(pid_1).task_description == "Task 1"
    assert PlanningPoker.Round.show_round(pid_2).task_description == "Task 2"
    assert PlanningPoker.Round.show_round(pid_3).task_description == "Task 3"
  end
end
