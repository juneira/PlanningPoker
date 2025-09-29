defmodule PlanningPoker.Entity.Game do
  @enforce_keys [:uuid, :title, :owner, :rounds, :players, :created_at]
  defstruct [
    :uuid,
    :title,
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
          rounds: map() | nil,
          players: list() | nil,
          status: atom() | nil,
          created_at: DateTime.t() | nil,
          finished_at: DateTime.t() | nil
        }
end
