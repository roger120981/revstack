defmodule RevstackWeb.AdminDashboardLiveTest do
  use RevstackWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Revstack.TestSupport.AuthFixtures

  alias Revstack.Tracking.Service

  test "dashboard shows accurate lead and estimate counts", %{conn: conn} do
    admin = create_and_sign_in_user(%{admin?: true})

    create_lead(%{status: :new})
    create_lead(%{status: :new})
    create_lead(%{status: :contacted})
    create_lead(%{status: :closed})

    create_estimate_request(%{status: :new})
    create_estimate_request(%{status: :responded})

    conn = log_in_user(conn, admin)
    {:ok, view, _html} = live(conn, ~p"/admin")

    assert has_element?(view, "#dashboard-total-leads", "4")
    assert has_element?(view, "#dashboard-new-leads", "2")
    assert has_element?(view, "#dashboard-total-estimates", "2")
    assert has_element?(view, "#dashboard-new-estimates", "1")

    assert has_element?(
             view,
             "#dashboard-system-environment",
             to_string(Application.fetch_env!(:revstack, :environment))
           )

    assert has_element?(
             view,
             "#dashboard-system-app-version",
             to_string(Application.spec(:revstack, :vsn))
           )

    assert has_element?(view, "a[href='/admin/leads']", "View all leads")
    assert has_element?(view, "a[href='/admin/estimates']", "View all estimate requests")
  end

  test "dashboard shows total resume views count", %{conn: conn} do
    admin = create_and_sign_in_user(%{admin?: true})

    {:ok, visitor1} = Service.find_or_create_visitor("198.51.100.60")
    Service.create_page_visit(visitor1, "/resume/view")
    Service.create_page_visit(visitor1, "/resume/view")

    {:ok, visitor2} = Service.find_or_create_visitor("198.51.100.61")
    Service.create_page_visit(visitor2, "/resume/view")

    # A download should not count as a view
    Service.create_page_visit(visitor2, "/resume/download")
    # A non-resume page visit should not count
    Service.create_page_visit(visitor2, "/about")

    conn = log_in_user(conn, admin)
    {:ok, view, _html} = live(conn, ~p"/admin")

    assert has_element?(view, "#dashboard-resume-views", "3")
  end

  test "dashboard shows total resume downloads count", %{conn: conn} do
    admin = create_and_sign_in_user(%{admin?: true})

    {:ok, visitor1} = Service.find_or_create_visitor("198.51.100.70")
    Service.create_page_visit(visitor1, "/resume/download")
    Service.create_page_visit(visitor1, "/resume/download")

    {:ok, visitor2} = Service.find_or_create_visitor("198.51.100.71")
    Service.create_page_visit(visitor2, "/resume/download")

    # A view should not count as a download
    Service.create_page_visit(visitor2, "/resume/view")

    conn = log_in_user(conn, admin)
    {:ok, view, _html} = live(conn, ~p"/admin")

    assert has_element?(view, "#dashboard-resume-downloads", "3")
  end

  test "dashboard shows zero resume views when none exist", %{conn: conn} do
    admin = create_and_sign_in_user(%{admin?: true})

    conn = log_in_user(conn, admin)
    {:ok, view, _html} = live(conn, ~p"/admin")

    assert has_element?(view, "#dashboard-resume-views", "0")
    assert has_element?(view, "#dashboard-resume-downloads", "0")
  end

  test "dashboard resume views card links to visitors with filter", %{conn: conn} do
    admin = create_and_sign_in_user(%{admin?: true})

    conn = log_in_user(conn, admin)
    {:ok, view, _html} = live(conn, ~p"/admin")

    assert has_element?(
             view,
             "#dashboard-resume-views[href='/admin/visitors?filter=has_resume_views']"
           )
  end

  test "dashboard resume downloads card links to visitors with filter", %{conn: conn} do
    admin = create_and_sign_in_user(%{admin?: true})

    conn = log_in_user(conn, admin)
    {:ok, view, _html} = live(conn, ~p"/admin")

    assert has_element?(
             view,
             "#dashboard-resume-downloads[href='/admin/visitors?filter=has_resume_downloads']"
           )
  end

  test "dashboard new leads card links to leads with status filter", %{conn: conn} do
    admin = create_and_sign_in_user(%{admin?: true})

    conn = log_in_user(conn, admin)
    {:ok, view, _html} = live(conn, ~p"/admin")

    assert has_element?(view, "#dashboard-new-leads[href='/admin/leads?status=new']")
  end

  test "dashboard new estimates card links to estimates with status filter", %{conn: conn} do
    admin = create_and_sign_in_user(%{admin?: true})

    conn = log_in_user(conn, admin)
    {:ok, view, _html} = live(conn, ~p"/admin")

    assert has_element?(view, "#dashboard-new-estimates[href='/admin/estimates?status=new']")
  end
end
