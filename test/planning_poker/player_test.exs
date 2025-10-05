defmodule PlanningPoker.PlayerTest do
  use ExUnit.Case, async: true
  alias PlanningPoker.Player

  setup do
    player = start_supervised!({Player, [uuid: "player_uuid", user_name: "Player One"]})
    %{player: player}
  end

  test "creates games and lists owned games", %{player: player} do
    {:ok, game_uuid1} = Player.create_game(player, "Game Title 1")
    {:ok, game_uuid2} = Player.create_game(player, "Game Title 2")

    owned_games = Player.list_owned_games(player)
    assert Enum.sort(owned_games) == Enum.sort([game_uuid1, game_uuid2])
  end

  test "enters games, lists entered games and plays cards", %{player: player} do
    game_uuid_1 = UUID.uuid4()
    game_uuid_2 = UUID.uuid4()
    game_uuid_3 = UUID.uuid4()

    {:ok, game1} =
      PlanningPoker.Game.start_link(
        uuid: game_uuid_1,
        title: "Game 1",
        owner_uuid: "another_player_1"
      )

    {:ok, game2} =
      PlanningPoker.Game.start_link(
        uuid: game_uuid_2,
        title: "Game 2",
        owner_uuid: "another_player_2"
      )

    {:ok, game3} =
      PlanningPoker.Game.start_link(
        uuid: game_uuid_3,
        title: "Game 3",
        owner_uuid: "another_player_3"
      )

    :ok = Player.enter_game(player, game_uuid_1)
    :ok = Player.enter_game(player, game_uuid_2)

    entered_games = Player.list_entered_games(player)

    assert Enum.sort(entered_games) == Enum.sort([game_uuid_1, game_uuid_2])

    {:ok, round_uuid_1} = PlanningPoker.Game.create_round(game1, "Task 1")
    {:ok, round_uuid_2} = PlanningPoker.Game.create_round(game2, "Task 2")
    {:ok, round_uuid_3} = PlanningPoker.Game.create_round(game3, "Task 3")

    :ok = Player.play_card(player, game_uuid_1, round_uuid_1, 5)
    :ok = Player.play_card(player, game_uuid_2, round_uuid_2, 3)
    {:error, :player_not_in_game} = Player.play_card(player, game_uuid_3, round_uuid_3, 8)
  end
end
