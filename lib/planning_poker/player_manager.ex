defmodule PlanningPoker.PlayerManager do
  use DynamicSupervisor
  alias PlanningPoker.Player

  @doc """
  Starts the PlayerManager supervisor.
  """
  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def create_player(name) do
    uuid = UUID.uuid4()

    DynamicSupervisor.start_child(__MODULE__, {Player, uuid: uuid, user_name: name})
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
