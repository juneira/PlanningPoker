defmodule PlanningPoker.Entity.Game do
  @enforce_keys [:uuid, :owner]
  defstruct [
    :uuid,
    :owner,
    :rounds,
    :players,
    :status,
    :created_at,
    :finished_at
  ]

  @type t :: %__MODULE__{
          uuid: String.t(),
          owner: PlanningPoker.Entity.Player.t(),
          rounds: list() | nil,
          players: list() | nil,
          status: atom() | nil,
          created_at: DateTime.t() | nil,
          finished_at: DateTime.t() | nil
        }
end
