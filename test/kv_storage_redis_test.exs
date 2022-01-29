defmodule KvStorageRedisTest do
  use ExUnit.Case
  doctest KvStorageRedis

  test "greets the world" do
    assert KvStorageRedis.hello() == :world
  end
end
