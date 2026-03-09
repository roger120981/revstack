defmodule Revstack.Repo do
  use AshPostgres.Repo,
    otp_app: :revstack

  @impl true
  def init(_type, config) do
    socket_options =
      config
      |> Keyword.get(:socket_options, [])
      |> ensure_socket_keepalive()

    {:ok, Keyword.put(config, :socket_options, socket_options)}
  end

  @impl true
  def installed_extensions do
    # Add extensions here, and the migration generator will install them.
    ["ash-functions", "citext"]
  end

  # Don't open unnecessary transactions
  # will default to `false` in 4.0
  @impl true
  def prefer_transaction? do
    false
  end

  @impl true
  def min_pg_version do
    %Version{major: 16, minor: 0, patch: 0}
  end

  defp ensure_socket_keepalive(socket_options) do
    if Enum.any?(socket_options, &keepalive_option?/1) do
      socket_options
    else
      [{:keepalive, true} | socket_options]
    end
  end

  defp keepalive_option?(:keepalive), do: true
  defp keepalive_option?({:keepalive, _value}), do: true
  defp keepalive_option?(_option), do: false
end
