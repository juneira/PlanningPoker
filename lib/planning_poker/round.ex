defmodule PlanningPoker.Round do
  use GenServer

  alias PlanningPoker.Entity.Round

  ## CLIENT

  @doc """
  Creates the round.
  """
  def start_link(opts) do
    round = %Round{
      uuid: UUID.uuid4(),
      game: Keyword.fetch!(opts, :game),
      cards: %{},
      task_description: Keyword.fetch!(opts, :task_description),
      status: :waiting,
      created_at: DateTime.utc_now()
    }

    GenServer.start_link(__MODULE__, round, name: opts[:name])
  end

  @doc """
  Plays card of a 'score' to a 'player_uuid'
  """
  def play_card(server, player_uuid, score) do
    GenServer.call(server, {:play_card, player_uuid, score})
  end

  @doc """
  Starts the round and wait for cards
  """
  def start(server) do
    GenServer.call(server, :start)
  end

  @doc """
  Finishes the round
  """
  def finish(server) do
    GenServer.call(server, :finish)
  end

  @doc """
  Shows all cards played
  """
  def show_cards(server) do
    GenServer.call(server, :show_cards)
  end

  ## SERVER

  @impl true
  def init(%Round{} = round) do
    {:ok, round}
  end

  @impl true
  def handle_call({:play_card, player_uuid, score}, _from, %Round{status: :running} = round) do
    new_round = put_card_to_round(round, player_uuid, score)
    {:reply, :ok, new_round}
  end

  @impl true
  def handle_call({:play_card, _player_uuid, _score}, _from, round) do
    {:reply, :error, round}
  end

  @impl true
  def handle_call(:start, _from, round) do
    case Round.change_status(round, :running) do
      {:ok, new_round} -> {:reply, :ok, new_round}
      {:error, :invalid_status} -> {:reply, :error, round}
    end
  end

  @impl true
  def handle_call(:finish, _from, round) do
    case Round.change_status(round, :finished) do
      {:ok, new_round} -> {:reply, :ok, new_round}
      {:error, :invalid_status} -> {:reply, :error, round}
    end
  end

  @impl true
  def handle_call(:show_cards, _from, round) do
    {:reply, round.cards, round}
  end

  defp put_card_to_round(round, player_uuid, score) do
    %{round | cards: Map.put(round.cards, player_uuid, score)}
  end
end
