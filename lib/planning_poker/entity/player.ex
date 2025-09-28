defmodule PlanningPoker.Entity.Player do
  @enforce_keys [:uuid, :name]
  defstruct [:uuid, :name]
end
