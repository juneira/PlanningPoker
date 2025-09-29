defmodule PlanningPoker.RoundTest do
  use ExUnit.Case, async: true

  setup do
    task_description = "Any Description"

    round =
      start_supervised!(
        {PlanningPoker.Round, [uuid: UUID.uuid4(), task_description: task_description]}
      )

    %{round: round}
  end

  test "plays cards", %{round: round} do
    assert PlanningPoker.Round.play_card(round, "test_player_one", 1) == :error

    assert PlanningPoker.Round.start(round) == :ok

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

    assert PlanningPoker.Round.finish(round) == :ok

    round_data = PlanningPoker.Round.show_round(round)
    assert round_data.score == 7 / 3
    assert round_data.status == :finished
    assert round_data.finished_at != nil
    assert round_data.started_at != nil

    assert round_data.cards == %{
             "test_player_one" => 2,
             "test_player_two" => 2,
             "test_player_three" => 3
           }
  end

  test "change status", %{round: round} do
    assert PlanningPoker.Round.finish(round) == :error
    assert PlanningPoker.Round.start(round) == :ok
    assert PlanningPoker.Round.start(round) == :error
    assert PlanningPoker.Round.finish(round) == :ok
    assert PlanningPoker.Round.finish(round) == :error
    assert PlanningPoker.Round.start(round) == :error
  end
end
