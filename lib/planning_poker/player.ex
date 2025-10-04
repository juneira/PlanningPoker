defmodule PlanningPoker.Player do
  use GenServer
  alias PlanningPoker.Entity.Player

  ## CLIENT

  @doc """
  Creates a new player with the given UUID and name.
  """
  def start_link(opts) do
    uuid = Keyword.fetch!(opts, :uuid)
    name = Keyword.fetch!(opts, :user_name)

    player = %Player{
      uuid: uuid,
      name: name,
      owner_games_uuids: MapSet.new(),
      player_games_uuids: MapSet.new()
    }

    GenServer.start_link(__MODULE__, player, name: opts[:name])
  end

  @doc """
  Creates a new game with the given a title.
  """
  def create_game(player, title) do
    GenServer.call(player, {:create_game, title})
  end

  @doc """
  Lists all games owned by the player.
  """
  def list_owned_games(player) do
    GenServer.call(player, :list_owned_games)
  end

  @doc """
  Enters a game as a player.
  """
  def enter_game(player, game_uuid) do
    GenServer.call(player, {:enter_game, game_uuid})
  end

  @doc """
  Lists all games the player has entered.
  """
  def list_entered_games(player) do
    GenServer.call(player, :list_entered_games)
  end

  ## SERVER

  @impl true
  def init(player) do
    {:ok, player}
  end

  @impl true
  def handle_call({:create_game, title}, _from, %Player{} = player) do
    game_uuid = UUID.uuid4()

    {:ok, _game_pid} =
      PlanningPoker.Game.start_link(uuid: game_uuid, owner_uuid: player.uuid, title: title)

    updated_owner_games_uuids = MapSet.put(player.owner_games_uuids, game_uuid)

    updated_player = %Player{player | owner_games_uuids: updated_owner_games_uuids}

    {:reply, {:ok, game_uuid}, updated_player}
  end

  @impl true
  def handle_call(:list_owned_games, _from, %Player{} = player) do
    {:reply, MapSet.to_list(player.owner_games_uuids), player}
  end

  @impl true
  def handle_call({:enter_game, game_uuid}, _from, %Player{} = player) do
    case PlanningPoker.Game.find_game(game_uuid) do
      {:ok, game_pid} ->
        :ok = PlanningPoker.Game.add_player(game_pid, player.uuid)

        updated_player_games_uuids = MapSet.put(player.player_games_uuids, game_uuid)
        updated_player = %Player{player | player_games_uuids: updated_player_games_uuids}
        {:reply, :ok, updated_player}

      {:error, :not_found} ->
        {:reply, {:error, :game_not_found}, player}
    end
  end

  @impl true
  def handle_call(:list_entered_games, _from, %Player{} = player) do
    {:reply, MapSet.to_list(player.player_games_uuids), player}
  end
end
