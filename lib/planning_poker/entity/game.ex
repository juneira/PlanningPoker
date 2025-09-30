defmodule PlanningPoker.Entity.Game do
  @enforce_keys [:uuid, :title, :owner, :rounds, :player_uuids, :created_at]
  defstruct [
    :uuid,
    :title,
    :owner,
    :rounds,
    :player_uuids,
    :created_at,
    :finished_at
  ]

  @type t :: %__MODULE__{
          uuid: String.t(),
          owner: PlanningPoker.Entity.Player.t(),
          rounds: map() | nil,
          player_uuids: map() | nil,
          created_at: DateTime.t() | nil,
          finished_at: DateTime.t() | nil
        }
end
