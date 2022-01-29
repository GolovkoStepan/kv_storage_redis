defmodule KvStorageRedis do
  @moduledoc """
  Модуль для работы с БД Redis
  """

  use GenServer

  defstruct host: nil, port: nil, db: nil, conn: nil

  ### Interface

  @doc ~S"""
  Запуск процесса

  ## Примеры

      iex> {:ok, _pid} = KvStorageRedis.start()

  """
  @spec start(any, any, any) :: :ignore | {:error, any} | {:ok, pid}
  def start(host \\ "localhost", port \\ 6379, db \\ 0) do
    GenServer.start_link(__MODULE__, %__MODULE__{host: host, port: port, db: db})
  end

  @doc ~S"""
  Возвращает конфигурацию процесса

  ## Примеры

      iex> {:ok, pid} = KvStorageRedis.start()
      iex> %KvStorageRedis{} = KvStorageRedis.config(pid)

  """
  @spec config(atom | pid | {atom, any} | {:via, atom, any}) :: any
  def config(pid) do
    GenServer.call(pid, :config)
  end

  @doc ~S"""
  Функция получения значения по ключу

  ## Примеры

      iex> {:ok, pid} = KvStorageRedis.start()
      iex> :ok = KvStorageRedis.set(pid, "k", 1)

  """
  @spec get(atom | pid | {atom, any} | {:via, atom, any}, any) :: any
  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  @doc ~S"""
  Функция сохранения значения

  ## Примеры

      iex> {:ok, pid} = KvStorageRedis.start()
      iex> KvStorageRedis.set(pid, "k", 1)
      iex> {:ok, "1"} = KvStorageRedis.get(pid, "k")

  """
  @spec set(atom | pid | {atom, any} | {:via, atom, any}, any, any) :: :ok
  def set(pid, key, value) do
    GenServer.cast(pid, {:set, key, value})
  end

  @doc """
  Функция сохранения значения с временем жизни

  ## Примеры

      iex> {:ok, pid} = KvStorageRedis.start()
      iex> :ok = KvStorageRedis.set(pid, "k", 1)

  """
  @spec setex(atom | pid | {atom, any} | {:via, atom, any}, any, any, any) :: :ok
  def setex(pid, key, value, ttl) do
    GenServer.cast(pid, {:setex, key, value, ttl})
  end

  ### Implementation

  @impl true
  def init(%__MODULE__{} = state) do
    {:ok, conn} = Redix.start_link(
      "redis://#{state.host}:#{state.port}/#{state.db}",
      name: :redix
    )

    {:ok, %{state | conn: conn}}
  end

  @impl true
  def handle_call(:config, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, Redix.command(state.conn, ["GET", key]), state}
  end

  @impl true
  def handle_cast({:set, key, value}, state) do
    Redix.command(state.conn, ["SET", key, value])
    {:noreply, state}
  end

  @impl true
  def handle_cast({:setex, key, value, ttl}, state) do
    Redix.command(state.conn, ["SETEX", key, ttl, value])
    {:noreply, state}
  end
end
