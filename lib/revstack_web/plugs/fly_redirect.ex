defmodule RevstackWeb.Plugs.FlyRedirect do
  @moduledoc """
  Redirects requests from the Fly app domain to the canonical external site.

  This plug is intended to run in production and is controlled via runtime config.
  """

  @behaviour Plug

  import Plug.Conn

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    redirect_config = Application.get_env(:revstack, __MODULE__, [])

    enabled? = Keyword.get(redirect_config, :enabled, false)
    source_host = Keyword.get(redirect_config, :source_host, "revstack.fly.dev")
    target_url = Keyword.get(redirect_config, :target_url, "https://revenuelink.net")

    if enabled? and host_matches?(conn.host, source_host) do
      conn
      |> put_resp_header("location", target_url)
      |> send_resp(301, "")
      |> halt()
    else
      conn
    end
  end

  defp host_matches?(host, source_host) do
    String.downcase(host || "") == String.downcase(source_host || "")
  end
end
