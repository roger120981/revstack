defmodule RevstackWeb.LayoutsNavigationTest do
  use RevstackWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "shared navigation exposes profile, services, estimate, and contact links", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#nav-brand", "Kyle Neal")
    assert has_element?(view, "#nav-home", "Profile")
    assert has_element?(view, "#nav-services", "Services")
    assert has_element?(view, "#nav-estimate", "Estimate")
    assert has_element?(view, "#nav-contact", "Contact")

    assert has_element?(view, "#mobile-nav-trigger")
    assert has_element?(view, "#mobile-nav-home", "Profile")
    assert has_element?(view, "#mobile-nav-services", "Services")
    assert has_element?(view, "#mobile-nav-estimate", "Estimate")
    assert has_element?(view, "#mobile-nav-contact", "Contact")
  end
end
