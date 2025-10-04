defmodule PlanningPoker.GameTest do
  use ExUnit.Case, async: true

  setup do
    owner_uuid = "owner_uuid"
    title = "Game Title"

    game =
      start_supervised!(
        {PlanningPoker.Game, [uuid: UUID.uuid4(), owner_uuid: owner_uuid, title: title]}
      )

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

  test "adds and removes players", %{game: game} do
    player1_uuid = "player1_uuid"
    player2_uuid = "player2_uuid"
    player3_uuid = "player3_uuid"

    assert :ok = PlanningPoker.Game.add_player(game, player1_uuid)
    assert :ok = PlanningPoker.Game.add_player(game, player2_uuid)
    assert :ok = PlanningPoker.Game.add_player(game, player3_uuid)
    assert {:error, :player_already_exists} = PlanningPoker.Game.add_player(game, player2_uuid)

    players = PlanningPoker.Game.get_players(game)

    assert Enum.sort(players) ==
             Enum.sort([player1_uuid, player2_uuid, player3_uuid, "owner_uuid"])

    assert :ok = PlanningPoker.Game.remove_player(game, player2_uuid)
    players_after_removal = PlanningPoker.Game.get_players(game)

    assert Enum.sort(players_after_removal) ==
             Enum.sort([player1_uuid, player3_uuid, "owner_uuid"])
  end

  test "plays cards in a round", %{game: game} do
    player1_uuid = "player1_uuid"
    player2_uuid = "player2_uuid"
    player3_uuid = "player3_uuid"

    :ok = PlanningPoker.Game.add_player(game, player1_uuid)
    :ok = PlanningPoker.Game.add_player(game, player2_uuid)
    :ok = PlanningPoker.Game.add_player(game, player3_uuid)

    assert {:ok, round_uuid} = PlanningPoker.Game.create_round(game, "Task for voting")
    assert {:ok, round_pid} = PlanningPoker.Game.lookup_round(game, round_uuid)

    assert :ok = PlanningPoker.Game.start_round(game, "owner_uuid", round_uuid)

    assert {:error, :player_not_in_game} =
             PlanningPoker.Game.play_card(game, round_uuid, "unknown_player", 5)

    assert PlanningPoker.Game.play_card(game, round_uuid, player1_uuid, 3) == :ok
    assert PlanningPoker.Game.play_card(game, round_uuid, player2_uuid, 5) == :ok
    assert PlanningPoker.Game.play_card(game, round_uuid, player3_uuid, 8) == :ok

    assert PlanningPoker.Round.show_cards(round_pid) == %{
             player1_uuid => 3,
             player2_uuid => 5,
             player3_uuid => 8
           }

    assert :ok = PlanningPoker.Round.finish(round_pid)
    assert PlanningPoker.Round.show_round(round_pid).status == :finished
  end
end
