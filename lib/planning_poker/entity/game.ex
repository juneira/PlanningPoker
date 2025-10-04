defmodule PlanningPoker.Entity.Game do
  @enforce_keys [:uuid, :title, :rounds, :owner_uuid, :player_uuids, :created_at]
  defstruct [
    :uuid,
    :title,
    :rounds,
    :owner_uuid,
    :player_uuids,
    :created_at,
    :finished_at
  ]

  @type t :: %__MODULE__{
          uuid: String.t(),
          rounds: map(),
          owner_uuid: String.t(),
          player_uuids: map(),
          created_at: DateTime.t(),
          finished_at: DateTime.t() | nil
        }
end
