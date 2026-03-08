defmodule RevstackWeb.Plugs.VisitorTracking do
  @moduledoc """
  Plug that captures visitor context and stores it in the session.

  Actual page-visit tracking for public routes happens in the LiveView session
  lifecycle so client-side `navigate` transitions are recorded as page visits.
  """

  @behaviour Plug

  alias Revstack.Tracking.Service

  @impl true
  def init(opts), do: opts

  @impl true
  def call(conn, _opts) do
    ip = Service.extract_ip(conn)
    user_agent = get_user_agent(conn)
    referrer = get_referrer(conn)

    conn
    |> Plug.Conn.assign(:visitor_ip, ip)
    |> Plug.Conn.assign(:visitor_user_agent, user_agent)
    |> Plug.Conn.assign(:visitor_referrer, referrer)
    |> Plug.Conn.put_session(:visitor_ip, ip)
    |> Plug.Conn.put_session(:visitor_user_agent, user_agent)
    |> Plug.Conn.put_session(:visitor_referrer, referrer)
  end

  defp get_user_agent(conn) do
    conn
    |> Plug.Conn.get_req_header("user-agent")
    |> List.first()
  end

  defp get_referrer(conn) do
    conn
    |> Plug.Conn.get_req_header("referer")
    |> List.first()
  end
end
