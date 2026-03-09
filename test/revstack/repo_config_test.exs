defmodule Revstack.RepoConfigTest do
  use ExUnit.Case, async: true

  test "uses safer production defaults when optional env vars are missing" do
    env = fn
      "DATABASE_URL" -> "ecto://postgres:postgres@db.internal/revstack"
      _key -> nil
    end

    assert [
             url: "ecto://postgres:postgres@db.internal/revstack",
             pool_size: 5,
             queue_target: 10_000,
             queue_interval: 5_000,
             socket_options: []
           ] = Revstack.RepoConfig.prod_repo_config(env)
  end

  test "uses ipv6 and explicit overrides when provided" do
    env = fn
      "DATABASE_URL" -> "ecto://postgres:postgres@db.internal/revstack"
      "ECTO_IPV6" -> "true"
      "POOL_SIZE" -> "7"
      "DB_QUEUE_TARGET" -> "12000"
      "DB_QUEUE_INTERVAL" -> "6000"
      _key -> nil
    end

    assert [
             url: "ecto://postgres:postgres@db.internal/revstack",
             pool_size: 7,
             queue_target: 12_000,
             queue_interval: 6_000,
             socket_options: [:inet6]
           ] = Revstack.RepoConfig.prod_repo_config(env)
  end

  test "raises when the database url is missing" do
    assert_raise RuntimeError, ~r/environment variable DATABASE_URL is missing/, fn ->
      Revstack.RepoConfig.prod_repo_config(fn _key -> nil end)
    end
  end
end
