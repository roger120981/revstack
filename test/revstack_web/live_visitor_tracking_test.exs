defmodule RevstackWeb.LiveVisitorTrackingTest do
  use RevstackWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  alias Revstack.Tracking.{Visitor, VisitorPageVisit}

  test "logs page visits for LiveView navigation between public routes", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")
    _ = :sys.get_state(view.pid)

    visitor = Visitor.by_ip!("127.0.0.1", authorize?: false)
    initial_visits = VisitorPageVisit.for_visitor!(visitor.id, authorize?: false)

    assert Enum.any?(initial_visits, &(&1.path == "/"))

    {:ok, contact_view, _html} =
      view
      |> element("a.btn.btn-primary.btn-lg[href='/contact']")
      |> render_click()
      |> follow_redirect(conn, ~p"/contact")

    _ = :sys.get_state(contact_view.pid)

    updated_visits = VisitorPageVisit.for_visitor!(visitor.id, authorize?: false)
    paths = Enum.map(updated_visits, & &1.path)

    assert "/" in paths
    assert "/contact" in paths
    assert length(updated_visits) >= length(initial_visits) + 1
  end

  test "logs page visits when navigating to another public route from a follow-up page", %{
    conn: conn
  } do
    {:ok, view, _html} = live(conn, ~p"/thanks")
    _ = :sys.get_state(view.pid)

    visitor = Visitor.by_ip!("127.0.0.1", authorize?: false)

    {:ok, home_view, _html} =
      view
      |> element("a.btn.btn-primary.btn-lg[href='/']")
      |> render_click()
      |> follow_redirect(conn, ~p"/")

    _ = :sys.get_state(home_view.pid)

    visits = VisitorPageVisit.for_visitor!(visitor.id, authorize?: false)
    paths = Enum.map(visits, & &1.path)

    assert "/thanks" in paths
    assert "/" in paths
  end
end
