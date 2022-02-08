defmodule KvStorageRedis.Log do
  @levels %{
    emergency: 8,
    alert: 7,
    critical: 6,
    error: 5,
    warning: 4,
    notice: 3,
    info: 2,
    debug: 1
  }

  @config Application.compile_env(:kv_storage_redis, __MODULE__, [])
  @conf_level Keyword.get(@config, :level, :info)
  @conf_priority Map.fetch!(@levels, @conf_level)

  @spec level :: :emergency | :alert | :critical | :error | :warning | :notice | :info | :debug
  def level, do: @conf_level

  for {level, _} <- @levels do
    def unquote(level)(msg), do: log(unquote(level), @levels[unquote(level)], msg)
  end

  defp log(level, priority, msg) when priority >= @conf_priority do
    IO.puts("#{DateTime.utc_now()} [#{level}]  #{msg}")
  end

  defp log(_, _, _), do: :ok
end
