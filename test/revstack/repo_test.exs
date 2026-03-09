defmodule Revstack.RepoTest do
  use ExUnit.Case, async: true

  test "adds TCP keepalive when socket options are missing" do
    assert {:ok, config} = Revstack.Repo.init(:supervisor, pool_size: 10)

    assert keepalive_enabled?(Keyword.fetch!(config, :socket_options))
  end

  test "preserves an explicit keepalive socket option" do
    assert {:ok, config} =
             Revstack.Repo.init(:supervisor,
               pool_size: 10,
               socket_options: [:inet6, keepalive: false]
             )

    assert {:keepalive, false} in Keyword.fetch!(config, :socket_options)
  end

  defp keepalive_enabled?(socket_options) do
    Enum.any?(socket_options, fn
      :keepalive -> true
      {:keepalive, true} -> true
      _option -> false
    end)
  end
end
