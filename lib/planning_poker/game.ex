defmodule PlanningPoker.Game do
  use GenServer

  alias PlanningPoker.Entity.Game

  ## CLIENT

  @doc """
  Creates the game.
  """
  def start_link(opts) do
    uuid = Keyword.fetch!(opts, :uuid)
    owner_uuid = Keyword.fetch!(opts, :owner_uuid)
    title = Keyword.fetch!(opts, :title)

    game = %Game{
      uuid: uuid,
      title: title,
      rounds: %{},
      owner_uuid: owner_uuid,
      player_uuids: MapSet.new([owner_uuid]),
      created_at: DateTime.utc_now()
    }

    GenServer.start_link(
      __MODULE__,
      game,
      name: {:via, Registry, {PlanningPoker.GameRegistry, uuid}}
    )
  end

  @doc """
  Finds a game by its UUID and returns its PID if found.
  """
  def find_game(game_uuid) do
    case Registry.lookup(PlanningPoker.GameRegistry, game_uuid) do
      [{pid, _value}] -> {:ok, pid}
      [] -> {:error, :not_found}
    end
  end

  @doc """
  Shows the current state of the game.
  """
  def show(server) do
    GenServer.call(server, :show)
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

  @doc """
  Adds a player UUID to the game if not already present.
  """
  def add_player(server, player_uuid) do
    GenServer.call(server, {:add_player, player_uuid})
  end

  @doc """
  Removes a player UUID from the game.
  """
  def remove_player(server, player_uuid) do
    GenServer.call(server, {:remove_player, player_uuid})
  end

  @doc """
  Gets all player UUIDs in the game.
  """
  def get_players(server) do
    GenServer.call(server, :get_players)
  end

  @doc """
  Starts a round in the game.
  """
  def start_round(server, owner_uuid, round_uuid) do
    GenServer.call(server, {:start_round, owner_uuid, round_uuid})
  end

  @doc """
  Play a card on round in the game.
  """
  def play_card(server, round_uuid, player_uuid, score) do
    GenServer.call(server, {:play_card, round_uuid, player_uuid, score})
  end

  ## SERVER

  @impl true
  def init(%Game{} = game) do
    {:ok, game}
  end

  @impl true
  def handle_call(:show, _from, %Game{} = game) do
    {:reply, game, game}
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
      {:ok, pid} -> {:reply, {:ok, pid}, game}
      :error -> {:reply, {:error, :not_found}, game}
    end
  end

  @impl true
  def handle_call({:add_player, player_uuid}, _from, %Game{} = game) do
    if MapSet.member?(game.player_uuids, player_uuid) do
      {:reply, {:error, :player_already_exists}, game}
    else
      new_players = MapSet.put(game.player_uuids, player_uuid)
      new_game = %{game | player_uuids: new_players}
      {:reply, :ok, new_game}
    end
  end

  @impl true
  def handle_call({:remove_player, player_uuid}, _from, %Game{} = game) do
    new_players = MapSet.delete(game.player_uuids, player_uuid)
    new_game = %{game | player_uuids: new_players}
    {:reply, :ok, new_game}
  end

  @impl true
  def handle_call(:get_players, _from, %Game{} = game) do
    players_list = MapSet.to_list(game.player_uuids)
    {:reply, players_list, game}
  end

  @impl true
  def handle_call({:start_round, owner_uuid, round_uuid}, _from, %Game{} = game)
      when game.owner_uuid == owner_uuid do
    case Map.fetch(game.rounds, round_uuid) do
      {:ok, round_pid} ->
        case PlanningPoker.Round.start(round_pid) do
          :ok -> {:reply, :ok, game}
          {:error, reason} -> {:reply, {:error, reason}, game}
        end

      :error ->
        {:reply, {:error, :not_found}, game}
    end
  end

  @impl true
  def handle_call({:start_round, _owner_uuid, _round_uuid}, _from, %Game{} = game) do
    {:reply, {:error, :not_owner}, game}
  end

  @impl true
  def handle_call({:play_card, round_uuid, player_uuid, score}, _from, %Game{} = game) do
    if MapSet.member?(game.player_uuids, player_uuid) do
      play_card_in_round(game, round_uuid, player_uuid, score)
    else
      {:reply, {:error, :player_not_in_game}, game}
    end
  end

  defp play_card_in_round(game, round_uuid, player_uuid, score) do
    case Map.fetch(game.rounds, round_uuid) do
      {:ok, round_pid} ->
        PlanningPoker.Round.play_card(round_pid, player_uuid, score)
        {:reply, :ok, game}

      :error ->
        {:reply, {:error, :not_found}, game}
    end
  end

  defp create_and_add_round(game, task_description) do
    round_uuid = UUID.uuid4()

    {:ok, pid} =
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
