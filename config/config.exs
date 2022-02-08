import Config

config :kv_storage_redis, :redis_path, "redis://127.0.0.1:6379/0"

config :kv_storage_redis, KvStorageRedis.Log, level: :warning
