defmodule RevstackWeb.AdminDashboardLiveTest do
  use RevstackWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Revstack.TestSupport.AuthFixtures

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

    assert has_element?(view, "a[href='/admin/leads']", "View all leads")
    assert has_element?(view, "a[href='/admin/estimates']", "View all estimate requests")
  end
end
