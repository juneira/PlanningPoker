defmodule PlanningPoker.Entity.Player do
  @enforce_keys [:uuid, :name, :owner_games_uuids, :player_games_uuids]
  defstruct [:uuid, :name, :owner_games_uuids, :player_games_uuids]

  @type t :: %__MODULE__{
          uuid: String.t(),
          name: String.t(),
          owner_games_uuids: MapSet.t(),
          player_games_uuids: MapSet.t()
        }
end
