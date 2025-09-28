defmodule PlanningPoker.Entity.Round do
  @enforce_keys [:uuid, :game, :task_description, :created_at]
  defstruct [
    :uuid,
    :game,
    :task_description,
    :cards,
    :score,
    :status,
    :created_at,
    :started_at,
    :finished_at
  ]
end
