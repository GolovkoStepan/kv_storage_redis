defmodule KvStorageRedis do
  @moduledoc """
  Модуль для работы с БД Redis
  """

  use GenServer

  defstruct redix_name: nil

  @typedoc "Конфигурация хранилища"
  @type t :: %{
          __struct__: __MODULE__,
          redix_name: atom()
        }

  ### Interface

  @doc ~S"""
  Запуск процесса

  ## Примеры

      iex> {:ok, _pid} = KvStorageRedis.start_link(%{redix_name: :redix, kv_name: :kv})

  """
  @spec start_link(%{redix_name: atom(), kv_name: atom()}) :: GenServer.on_start()
  def start_link(%{redix_name: redix_name, kv_name: kv_name}) do
    GenServer.start_link(__MODULE__, %__MODULE__{redix_name: redix_name}, name: kv_name)
  end

  @doc ~S"""
  Возвращает конфигурацию процесса

  ## Примеры

      iex> {:ok, pid} = KvStorageRedis.start_link(%{redix_name: :redix, kv_name: :kv})
      iex> %KvStorageRedis{} = KvStorageRedis.config(pid)

  """
  @spec config(GenServer.server()) :: t()
  def config(pid) do
    GenServer.call(pid, :config)
  end

  @doc ~S"""
  Функция получения значения по ключу

  ## Примеры

      iex> {:ok, pid} = KvStorageRedis.start_link(%{redix_name: :redix, kv_name: :kv})
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

      iex> {:ok, pid} = KvStorageRedis.start_link(%{redix_name: :redix, kv_name: :kv})
      iex> :ok = KvStorageRedis.set(pid, "k", 1)

  """
  @spec set(pid(), String.t(), String.t()) :: :ok
  def set(pid, key, value) do
    GenServer.cast(pid, {:set, key, value})
  end

  @doc """
  Функция сохранения значения с временем жизни

  ## Примеры

      iex> {:ok, pid} = KvStorageRedis.start_link(%{redix_name: :redix, kv_name: :kv})
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
    {:reply, Redix.command(Process.whereis(state.redix_name), ["GET", key]), state}
  end

  @impl true
  def handle_cast({:set, key, value}, state) do
    Redix.command(Process.whereis(state.redix_name), ["SET", key, value])
    {:noreply, state}
  end

  @impl true
  def handle_cast({:set, key, value, ttl}, state) do
    Redix.command(Process.whereis(state.redix_name), ["SETEX", key, ttl, value])
    {:noreply, state}
  end
end
