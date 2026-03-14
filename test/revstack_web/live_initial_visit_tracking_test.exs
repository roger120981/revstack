defmodule RevstackWeb.LiveInitialVisitTrackingTest do
  use RevstackWeb.ConnCase, async: false

  import Phoenix.LiveViewTest

  alias Revstack.Tracking.{Visitor, VisitorPageVisit}

  describe "initial page visit to / is tracked" do
    test "records a page visit for / on first LiveView mount", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")
      _ = :sys.get_state(view.pid)

      visitor = Visitor.by_ip!("127.0.0.1", authorize?: false)
      visits = VisitorPageVisit.for_visitor!(visitor.id, authorize?: false)

      assert Enum.any?(visits, &(&1.path == "/"))
    end

    test "creates the visitor record on initial visit", %{conn: conn} do
      assert {:error, _} = Visitor.by_ip("127.0.0.1", authorize?: false)

      {:ok, view, _html} = live(conn, ~p"/")
      _ = :sys.get_state(view.pid)

      assert {:ok, visitor} = Visitor.by_ip("127.0.0.1", authorize?: false)
      assert visitor.ip_address == "127.0.0.1"
      assert visitor.visit_count >= 1
    end

    test "records the correct path and method for /", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")
      _ = :sys.get_state(view.pid)

      visitor = Visitor.by_ip!("127.0.0.1", authorize?: false)
      visits = VisitorPageVisit.for_visitor!(visitor.id, authorize?: false)

      root_visit = Enum.find(visits, &(&1.path == "/"))
      assert root_visit
      assert root_visit.method == "GET"
      assert root_visit.full_url =~ "/"
    end

    test "records visit to /whoami on initial mount", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/whoami")
      _ = :sys.get_state(view.pid)

      visitor = Visitor.by_ip!("127.0.0.1", authorize?: false)
      visits = VisitorPageVisit.for_visitor!(visitor.id, authorize?: false)

      assert Enum.any?(visits, &(&1.path == "/whoami"))
    end

    test "records visit to /services on initial mount", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/services")
      _ = :sys.get_state(view.pid)

      visitor = Visitor.by_ip!("127.0.0.1", authorize?: false)
      visits = VisitorPageVisit.for_visitor!(visitor.id, authorize?: false)

      assert Enum.any?(visits, &(&1.path == "/services"))
    end
  end
end
