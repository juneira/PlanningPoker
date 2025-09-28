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
end
