defmodule RevstackWeb.AdminAuthAccessTest do
  use RevstackWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Revstack.TestSupport.AuthFixtures

  test "sign-in page renders password authentication and not magic-link UI", %{conn: conn} do
    conn = get(conn, ~p"/sign-in")
    html = html_response(conn, 200)

    assert html =~ "user-password-sign-in-with-password"
    assert html =~ ~s(type="password")
    refute html =~ "magic-sign-in-banner"
  end

  test "unauthenticated users are redirected away from admin routes", %{conn: conn} do
    for path <- [~p"/admin", ~p"/admin/leads", ~p"/admin/estimates"] do
      redirected_conn = get(conn, path)
      assert redirected_to(redirected_conn) == ~p"/sign-in"
    end
  end

  test "non-admin users are redirected away from admin routes", %{conn: conn} do
    user = create_and_sign_in_user()

    for path <- [~p"/admin", ~p"/admin/leads", ~p"/admin/estimates"] do
      redirected_conn =
        conn
        |> recycle()
        |> log_in_user(user)
        |> get(path)

      assert redirected_to(redirected_conn) == ~p"/"
    end
  end

  test "admins can access dashboard, index pages, and show pages", %{conn: conn} do
    admin = create_and_sign_in_user(%{admin?: true})
    lead = create_lead(%{name: "Access Test Lead"})

    estimate =
      create_estimate_request(%{
        name: "Access Test Estimate",
        summary: "This summary is long enough to verify access to estimate pages cleanly."
      })

    conn = log_in_user(conn, admin)

    {:ok, dashboard_view, _html} = live(conn, ~p"/admin")
    assert has_element?(dashboard_view, "#dashboard-total-leads")

    {:ok, leads_view, _html} = live(conn, ~p"/admin/leads")
    assert has_element?(leads_view, "#leads-table")
    assert render(leads_view) =~ "Access Test Lead"

    {:ok, lead_view, _html} = live(conn, ~p"/admin/leads/#{lead.id}")
    assert render(lead_view) =~ "Contact Information"

    {:ok, estimates_view, _html} = live(conn, ~p"/admin/estimates")
    assert has_element?(estimates_view, "#estimates-table")
    assert render(estimates_view) =~ "Access Test Estimate"

    {:ok, estimate_view, _html} = live(conn, ~p"/admin/estimates/#{estimate.id}")
    assert render(estimate_view) =~ "Project Details"
  end

  test "admin layout renders a centered brand logo that fills the sidebar header", %{conn: conn} do
    admin = create_and_sign_in_user(%{admin?: true})
    conn = log_in_user(conn, admin)

    {:ok, view, _html} = live(conn, ~p"/admin")

    assert has_element?(view, "#desktop-brand-logo")
    assert has_element?(view, "#desktop-brand-logo-image")
    assert has_element?(view, "#mobile-brand-logo")
    assert has_element?(view, "#mobile-brand-logo-image")

    html = render(view)
    document = LazyHTML.from_fragment(html)

    desktop_logo = LazyHTML.query_by_id(document, "desktop-brand-logo")
    desktop_logo_image = LazyHTML.query_by_id(document, "desktop-brand-logo-image")

    assert has_class?(desktop_logo, "relative")
    assert has_class?(desktop_logo, "h-12")
    assert has_class?(desktop_logo, "w-56")
    assert has_class?(desktop_logo, "overflow-hidden")

    assert has_class?(desktop_logo_image, "absolute")
    assert has_class?(desktop_logo_image, "left-1/2")
    assert has_class?(desktop_logo_image, "top-1/2")
    assert has_class?(desktop_logo_image, "w-[150%]")
    assert has_class?(desktop_logo_image, "-translate-x-1/2")
    assert has_class?(desktop_logo_image, "-translate-y-1/2")
  end

  test "admin layout renders the top bar search, UTC clock, notification bell, user menu, and theme toggle",
       %{
         conn: conn
       } do
    admin = create_and_sign_in_user(%{admin?: true})
    conn = log_in_user(conn, admin)

    {:ok, view, _html} = live(conn, ~p"/admin")

    assert has_element?(view, "#admin-topbar-search")

    assert has_element?(
             view,
             "#admin-topbar-search-input[placeholder='Search...'][disabled]"
           )

    assert has_element?(view, "#admin-topbar-utc-clock", "UTC")

    assert has_element?(
             view,
             "#admin-topbar-utc-clock[phx-hook='AdminUtcClock'][phx-update='ignore'][data-utc-time]"
           )

    assert has_element?(view, "#admin-topbar-utc-clock [data-role='utc-time-value']")
    assert has_element?(view, "#admin-topbar-notification-bell")
    assert has_element?(view, "#admin-topbar-user-menu-button", to_string(admin.email))
    assert has_element?(view, "#admin-topbar-user-menu", "Signed in")
    assert has_element?(view, "#admin-topbar-user-menu a[href='/sign-out']", "Sign out")
    assert has_element?(view, "#admin-topbar-theme-toggle")
    assert has_element?(view, "#admin-topbar-theme-toggle [data-phx-theme='system']")
    assert has_element?(view, "#admin-topbar-theme-toggle [data-phx-theme='light']")
    assert has_element?(view, "#admin-topbar-theme-toggle [data-phx-theme='dark']")
    assert has_element?(view, "#admin-page-title", "Dashboard")

    html = render(view)
    document = LazyHTML.from_fragment(html)
    user_menu = LazyHTML.query_by_id(document, "admin-topbar-user-menu")

    assert has_class?(user_menu, "hidden")
  end

  defp has_class?(lazy_html, class_name) do
    tree = LazyHTML.to_tree(lazy_html, sort_attributes: true, skip_whitespace_nodes: true)

    case tree do
      [{_tag, attrs, _children}] ->
        Enum.any?(attrs, fn
          {"class", class_value} -> String.contains?(class_value, class_name)
          _ -> false
        end)

      _ ->
        false
    end
  end
end
