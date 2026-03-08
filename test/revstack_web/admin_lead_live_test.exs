defmodule RevstackWeb.AdminLeadLiveTest do
  use RevstackWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Revstack.TestSupport.AuthFixtures

  require Ash.Query

  setup %{conn: conn} do
    admin = create_and_sign_in_user(%{admin?: true})
    {:ok, conn: log_in_user(conn, admin)}
  end

  test "index renders leads and filters by status", %{conn: conn} do
    create_lead(%{name: "Fresh Lead", status: :new})
    create_lead(%{name: "Contacted Lead", status: :contacted})
    create_lead(%{name: "Closed Lead", status: :closed})

    {:ok, view, _html} = live(conn, ~p"/admin/leads")

    assert render(view) =~ "Fresh Lead"
    assert render(view) =~ "Contacted Lead"
    assert render(view) =~ "Closed Lead"

    view
    |> element("button[phx-click='filter_status'][phx-value-status='new']")
    |> render_click()

    assert has_element?(view, "#leads-table tr", "Fresh Lead")
    refute has_element?(view, "#leads-table tr", "Contacted Lead")
    refute has_element?(view, "#leads-table tr", "Closed Lead")

    view
    |> element("button[phx-click='filter_status'][phx-value-status='closed']")
    |> render_click()

    assert has_element?(view, "#leads-table tr", "Closed Lead")
    refute has_element?(view, "#leads-table tr", "Fresh Lead")
  end

  test "index deletes a lead from the stream and database", %{conn: conn} do
    lead = create_lead(%{name: "Delete Me Lead"})

    {:ok, view, _html} = live(conn, ~p"/admin/leads")
    assert has_element?(view, "#leads-table tr", "Delete Me Lead")

    view
    |> element("button[phx-click='delete'][phx-value-id='#{lead.id}']")
    |> render_click()

    refute has_element?(view, "#leads-table tr", "Delete Me Lead")
    assert render(view) =~ "Lead deleted"

    assert [] ==
             Revstack.Consulting.Lead
             |> Ash.Query.filter(id == ^lead.id)
             |> Ash.read!(authorize?: false)
  end

  test "show page renders details and updates the lead status", %{conn: conn} do
    lead =
      create_lead(%{
        name: "Show Lead",
        company: "Acme Corp",
        preferred_contact_method: :phone,
        phone: "555-111-2222",
        source: "contact-form"
      })

    {:ok, view, _html} = live(conn, ~p"/admin/leads/#{lead.id}")

    assert render(view) =~ "Show Lead"
    assert render(view) =~ "Acme Corp"
    assert render(view) =~ "555-111-2222"
    assert render(view) =~ "contact-form"

    view
    |> element("a[href='/admin/leads/#{lead.id}/edit']")
    |> render_click()

    assert_patch(view, ~p"/admin/leads/#{lead.id}/edit")
    assert has_element?(view, "#lead-status-form")

    view
    |> form("#lead-status-form", %{"form" => %{"status" => "closed"}})
    |> render_submit()

    assert_patch(view, ~p"/admin/leads/#{lead.id}")
    assert render(view) =~ "Lead updated"
    assert render(view) =~ "Closed"

    updated_lead = Revstack.Consulting.Lead |> Ash.get!(lead.id, authorize?: false)
    assert updated_lead.status == :closed
  end

  test "show edit mode can be cancelled without persisting changes", %{conn: conn} do
    lead = create_lead(%{status: :new})

    {:ok, view, _html} = live(conn, ~p"/admin/leads/#{lead.id}/edit")
    assert has_element?(view, "#lead-status-form")

    view
    |> element("button[phx-click='cancel_edit']")
    |> render_click()

    assert_patch(view, ~p"/admin/leads/#{lead.id}")
    refute has_element?(view, "#lead-status-form")

    unchanged_lead = Revstack.Consulting.Lead |> Ash.get!(lead.id, authorize?: false)
    assert unchanged_lead.status == :new
  end
end
