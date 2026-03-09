defmodule Revstack.RepoConfig do
  @moduledoc false

  @default_pool_size 5
  @default_queue_target 10_000
  @default_queue_interval 5_000

  def prod_repo_config(env_fun \\ &System.get_env/1) when is_function(env_fun, 1) do
    database_url =
      env_fun.("DATABASE_URL") ||
        raise """
        environment variable DATABASE_URL is missing.
        For example: ecto://USER:PASS@HOST/DATABASE
        """

    maybe_ipv6 = if env_fun.("ECTO_IPV6") in ~w(true 1), do: [:inet6], else: []

    [
      url: database_url,
      pool_size: integer_env(env_fun, "POOL_SIZE", @default_pool_size),
      queue_target: integer_env(env_fun, "DB_QUEUE_TARGET", @default_queue_target),
      queue_interval: integer_env(env_fun, "DB_QUEUE_INTERVAL", @default_queue_interval),
      socket_options: maybe_ipv6
    ]
  end

  defp integer_env(env_fun, key, default) do
    case env_fun.(key) do
      nil ->
        default

      value ->
        String.to_integer(value)
    end
  end
end
