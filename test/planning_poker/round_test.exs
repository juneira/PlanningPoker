defmodule PlanningPoker.RoundTest do
  use ExUnit.Case, async: true

  setup do
    game = %PlanningPoker.Entity.Game{uuid: "uuid", owner: "any"}
    task_description = "Any Description"

    round =
      start_supervised!({PlanningPoker.Round, [game: game, task_description: task_description]})

    %{round: round}
  end

  test "plays cards", %{round: round} do
    assert PlanningPoker.Round.play_card(round, "test_player_one", 1) == :ok
    assert PlanningPoker.Round.show_cards(round) == %{"test_player_one" => 1}

    assert PlanningPoker.Round.play_card(round, "test_player_two", 2) == :ok
    assert PlanningPoker.Round.play_card(round, "test_player_three", 3) == :ok

    assert PlanningPoker.Round.show_cards(round) == %{
             "test_player_one" => 1,
             "test_player_two" => 2,
             "test_player_three" => 3
           }

    assert PlanningPoker.Round.play_card(round, "test_player_one", 2)

    assert PlanningPoker.Round.show_cards(round) == %{
             "test_player_one" => 2,
             "test_player_two" => 2,
             "test_player_three" => 3
           }
  end
end
