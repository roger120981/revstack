defmodule RevstackWeb.Plugs.FlyRedirectTest do
  use RevstackWeb.ConnCase, async: true

  alias RevstackWeb.Plugs.FlyRedirect

  describe "call/2" do
    setup do
      original_config = Application.get_env(:revstack, FlyRedirect, [])

      on_exit(fn ->
        Application.put_env(:revstack, FlyRedirect, original_config)
      end)

      :ok
    end

    test "redirects when enabled and host matches source host", %{conn: conn} do
      Application.put_env(:revstack, FlyRedirect,
        enabled: true,
        source_host: "revstack.fly.dev",
        target_url: "https://revenuelink.net"
      )

      conn =
        conn
        |> Map.put(:host, "revstack.fly.dev")
        |> FlyRedirect.call([])

      assert conn.halted
      assert conn.status == 301
      assert get_resp_header(conn, "location") == ["https://revenuelink.net"]
    end

    test "does not redirect when disabled", %{conn: conn} do
      Application.put_env(:revstack, FlyRedirect,
        enabled: false,
        source_host: "revstack.fly.dev",
        target_url: "https://revenuelink.net"
      )

      conn =
        conn
        |> Map.put(:host, "revstack.fly.dev")
        |> FlyRedirect.call([])

      refute conn.halted
      assert conn.status == nil
      assert get_resp_header(conn, "location") == []
    end

    test "does not redirect for non-matching host", %{conn: conn} do
      Application.put_env(:revstack, FlyRedirect,
        enabled: true,
        source_host: "revstack.fly.dev",
        target_url: "https://revenuelink.net"
      )

      conn =
        conn
        |> Map.put(:host, "example.com")
        |> FlyRedirect.call([])

      refute conn.halted
      assert conn.status == nil
      assert get_resp_header(conn, "location") == []
    end
  end
end
