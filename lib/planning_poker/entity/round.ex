defmodule PlanningPoker.Entity.Round do
  @enforce_keys [:uuid, :task_description, :status, :created_at]
  defstruct [
    :uuid,
    :task_description,
    :cards,
    :score,
    :status,
    :created_at,
    :started_at,
    :finished_at
  ]

  @type status :: :waiting | :running | :finished
  @type t :: %__MODULE__{
          uuid: String.t(),
          task_description: String.t(),
          cards: list() | nil,
          score: number() | nil,
          status: status(),
          created_at: DateTime.t(),
          started_at: DateTime.t() | nil,
          finished_at: DateTime.t() | nil
        }

  @doc """
  Changes the status of the round, ensuring valid transitions.
  """
  @spec change_status(t(), status()) :: {:ok, t()} | {:error, :invalid_status}
  def change_status(round, state)

  def change_status(%__MODULE__{status: :waiting} = round, :running) do
    {:ok, %{round | status: :running, started_at: DateTime.utc_now()}}
  end

  def change_status(%__MODULE__{status: :running} = round, :finished) do
    finished_data = %{
      status: :finished,
      finished_at: DateTime.utc_now(),
      score: calculate_score(round.cards)
    }

    {:ok, Map.merge(round, finished_data)}
  end

  def change_status(%__MODULE__{}, _new_status) do
    {:error, :invalid_status}
  end

  defp calculate_score(cards) do
    if map_size(cards) == 0 do
      0
    else
      total = Enum.reduce(cards, 0, fn {_player_uuid, score}, acc -> acc + score end)
      total / map_size(cards)
    end
  end
end
