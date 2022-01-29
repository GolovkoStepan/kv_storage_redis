defmodule KvStorageRedis do
  @moduledoc """
  Модуль для работы с БД Redis
  """

  use GenServer

  defstruct redis_conn: nil

  @typedoc "Конфигурация хранилища"
  @type t :: %{
          __struct__: __MODULE__,
          conn: pid()
        }

  ### Interface

  @doc ~S"""
  Запуск процесса

  ## Примеры

      iex> {:ok, conn} = Redix.start_link("redis://127.0.0.1:6379/0", name: :redix)
      iex> {:ok, _pid} = KvStorageRedis.start_link(conn)

  """
  @spec start_link(pid()) :: GenServer.on_start()
  def start_link(redis_conn) do
    GenServer.start_link(__MODULE__, %__MODULE__{redis_conn: redis_conn})
  end

  @doc ~S"""
  Возвращает конфигурацию процесса

  ## Примеры

      iex> {:ok, conn} = Redix.start_link("redis://127.0.0.1:6379/0", name: :redix)
      iex> {:ok, pid} = KvStorageRedis.start_link(conn)
      iex> %KvStorageRedis{} = KvStorageRedis.config(pid)

  """
  @spec config(GenServer.server()) :: t()
  def config(pid) do
    GenServer.call(pid, :config)
  end

  @doc ~S"""
  Функция получения значения по ключу

  ## Примеры

      iex> {:ok, conn} = Redix.start_link("redis://127.0.0.1:6379/0", name: :redix)
      iex> {:ok, pid} = KvStorageRedis.start_link(conn)
      iex> :ok = KvStorageRedis.set(pid, "k", "1")
      iex> {:ok, "1"} = KvStorageRedis.get(pid, "k")

  """
  @spec get(pid(), String.t()) :: {:ok, String.t()} | {:ok, nil}
  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  @doc ~S"""
  Функция сохранения значения

  ## Примеры

      iex> {:ok, conn} = Redix.start_link("redis://127.0.0.1:6379/0", name: :redix)
      iex> {:ok, pid} = KvStorageRedis.start_link(conn)
      iex> :ok = KvStorageRedis.set(pid, "k", 1)

  """
  @spec set(pid(), String.t(), String.t()) :: :ok
  def set(pid, key, value) do
    GenServer.cast(pid, {:set, key, value})
  end

  @doc """
  Функция сохранения значения с временем жизни

  ## Примеры

      iex> {:ok, conn} = Redix.start_link("redis://127.0.0.1:6379/0", name: :redix)
      iex> {:ok, pid} = KvStorageRedis.start_link(conn)
      iex> :ok = KvStorageRedis.set(pid, "k", 1)

  """
  @spec set(pid(), String.t(), String.t(), non_neg_integer()) :: :ok
  def set(pid, key, value, ttl) do
    GenServer.cast(pid, {:setex, key, value, ttl})
  end

  ### Implementation

  @impl true
  def init(%__MODULE__{} = state) do
    {:ok, state}
  end

  @impl true
  def handle_call(:config, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call({:get, key}, _from, state) do
    {:reply, Redix.command(state.redis_conn, ["GET", key]), state}
  end

  @impl true
  def handle_cast({:set, key, value}, state) do
    Redix.command(state.redis_conn, ["SET", key, value])
    {:noreply, state}
  end

  @impl true
  def handle_cast({:set, key, value, ttl}, state) do
    Redix.command(state.redis_conn, ["SETEX", key, ttl, value])
    {:noreply, state}
  end
end
