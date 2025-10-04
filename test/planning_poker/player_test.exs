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

  test "enters games and lists entered games", %{player: player} do
    game_uuid_1 = UUID.uuid4()
    game_uuid_2 = UUID.uuid4()

    {:ok, _game1} =
      PlanningPoker.Game.start_link(
        uuid: game_uuid_1,
        title: "Game 1",
        owner_uuid: "another_player_1"
      )

    {:ok, _game2} =
      PlanningPoker.Game.start_link(
        uuid: game_uuid_2,
        title: "Game 2",
        owner_uuid: "another_player_2"
      )

    :ok = Player.enter_game(player, game_uuid_1)
    :ok = Player.enter_game(player, game_uuid_2)

    entered_games = Player.list_entered_games(player)

    assert Enum.sort(entered_games) == Enum.sort([game_uuid_1, game_uuid_2])
  end
end
