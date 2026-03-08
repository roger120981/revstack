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
    html = render(view)

    assert html =~ ~r/id="dashboard-total-leads"[\s\S]*?>4<[
\s\S]*?Total Leads/
    assert html =~ ~r/id="dashboard-new-leads"[\s\S]*?>2<[
\s\S]*?New Leads/
    assert html =~ ~r/id="dashboard-total-estimates"[\s\S]*?>2<[
\s\S]*?Total Estimates/
    assert html =~ ~r/id="dashboard-new-estimates"[\s\S]*?>1<[
\s\S]*?New Estimates/
    assert html =~ "Single Admin Mode"
    assert html =~ "View all leads"
    assert html =~ "View all estimate requests"
  end
end
