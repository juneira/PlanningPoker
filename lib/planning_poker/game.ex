defmodule PlanningPoker.Game do
  use GenServer

  alias PlanningPoker.Entity.Game

  ## CLIENT

  @doc """
  Creates the game.
  """
  def start_link(opts) do
    uuid = Keyword.fetch!(opts, :uuid)
    owner = Keyword.fetch!(opts, :owner)
    title = Keyword.fetch!(opts, :title)

    game = %Game{
      uuid: uuid,
      title: title,
      owner: owner,
      rounds: %{},
      players: [owner],
      created_at: DateTime.utc_now()
    }

    GenServer.start_link(__MODULE__, game, name: opts[:name])
  end

  @doc """
  Creates a new round in the game with the given task description.
  """
  def create_round(server, task_description) do
    GenServer.call(server, {:create_round, task_description})
  end

  @doc """
  Looks up a round by its UUID and returns its PID if found.
  """
  def lookup_round(server, round_uuid) do
    GenServer.call(server, {:lookup, round_uuid})
  end

  ## SERVER

  @impl true
  def init(%Game{} = game) do
    {:ok, game}
  end

  @impl true
  def handle_call({:create_round, task_description}, _from, %Game{} = game) do
    if task_description == nil or task_description == "" do
      {:reply, {:error, :invalid_task_description}, game}
    else
      create_and_add_round(game, task_description)
    end
  end

  @impl true
  def handle_call({:lookup, round_uuid}, _from, %Game{} = game) do
    case Map.fetch(game.rounds, round_uuid) do
      {:ok, pid} -> {:reply, pid, game}
      :error -> {:reply, {:error, :not_found}, game}
    end
  end

  defp create_and_add_round(game, task_description) do
    round_uuid = UUID.uuid4()

    pid =
      PlanningPoker.Round.start_link(
        uuid: round_uuid,
        task_description: task_description
      )

    new_game = put_round_to_game(game, round_uuid, pid)

    {:reply, {:ok, round_uuid}, new_game}
  end

  defp put_round_to_game(game, round_uuid, pid) do
    %{game | rounds: Map.put(game.rounds, round_uuid, pid)}
  end
end
