defmodule RevstackWeb.LayoutsNavigationTest do
  use RevstackWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "shared navigation exposes profile and services links", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#nav-brand", "Kyle Neal")
    assert has_element?(view, "#nav-home", "Profile")
    assert has_element?(view, "#nav-services", "Services")
    refute has_element?(view, "#nav-estimate")
    refute has_element?(view, "#nav-contact")

    assert has_element?(view, "#mobile-nav-trigger")
    assert has_element?(view, "#mobile-nav-home", "Profile")
    assert has_element?(view, "#mobile-nav-services", "Services")
    refute has_element?(view, "#mobile-nav-estimate")
    refute has_element?(view, "#mobile-nav-contact")
  end
end
