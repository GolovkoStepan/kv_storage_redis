defmodule KvStorageRedis.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Redix, {Application.fetch_env!(:kv_storage_redis, :redis_path), name: :redix}},
      {KvStorageRedis, %{redix_name: :redix, kv_name: :kv_common}}
    ]

    opts = [strategy: :one_for_one, name: KvStorageRedis.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
