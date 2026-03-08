defmodule RevstackWeb.Plugs.VisitorTrackingTest do
  use RevstackWeb.ConnCase, async: true

  describe "visitor tracking plug" do
    test "assigns visitor_ip and visitor_user_agent to conn", %{conn: conn} do
      conn =
        conn
        |> put_req_header("user-agent", "TestBot/1.0")
        |> get("/")

      assert get_session(conn, :visitor_ip) != nil
      assert get_session(conn, :visitor_user_agent) == "TestBot/1.0"
    end

    test "stores the request referrer in session", %{conn: conn} do
      conn =
        conn
        |> put_req_header("referer", "https://example.com/source")
        |> put_req_header("user-agent", "TrackingTest/1.0")
        |> get("/about")

      conn = fetch_session(conn)

      assert get_session(conn, :visitor_referrer) == "https://example.com/source"
    end

    test "stores visitor IP in session for LiveView access", %{conn: conn} do
      conn =
        conn
        |> get("/contact")

      assert get_session(conn, :visitor_ip) != nil
    end
  end
end
