defmodule PlanningPoker.Entity.Player do
  @enforce_keys [:uuid, :name]
  defstruct [:uuid, :name]

  @type t :: %__MODULE__{
          uuid: String.t(),
          name: String.t()
        }
end
