defmodule PlanningPoker.Entity.Card do
  @enforce_keys [:player]
  defstruct [:player, :score]
end
