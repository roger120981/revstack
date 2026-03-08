defmodule RevstackWeb.LayoutsUserMenuTest do
  use RevstackWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Revstack.TestSupport.AuthFixtures

  test "home page hides the signed-in menu when no user is present", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/")

    refute has_element?(view, "#desktop-user-menu")
    refute has_element?(view, "#mobile-user-menu")
    refute render(view) =~ "Signed In"
  end

  test "home page shows the signed-in menu and actions for authenticated users", %{conn: conn} do
    user = create_and_sign_in_user(%{admin?: true})
    conn = log_in_user(conn, user)

    {:ok, view, _html} = live(conn, ~p"/")

    assert has_element?(view, "#desktop-user-menu")
    assert has_element?(view, "#desktop-user-menu-admin-link")
    assert has_element?(view, "#desktop-user-menu-sign-out-link")
    assert has_element?(view, "#mobile-user-menu")
    assert render(view) =~ to_string(user.email)
  end

  test "whoami page includes the admin panel project card", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/whoami")

    assert has_element?(view, "a[href='/admin']", "Admin Panel (Phoenix LiveView)")
  end
end
