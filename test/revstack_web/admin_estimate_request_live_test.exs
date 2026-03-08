defmodule RevstackWeb.AdminEstimateRequestLiveTest do
  use RevstackWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Revstack.TestSupport.AuthFixtures

  require Ash.Query

  setup %{conn: conn} do
    admin = create_and_sign_in_user(%{admin?: true})
    {:ok, conn: log_in_user(conn, admin)}
  end

  test "index renders estimates and filters by status", %{conn: conn} do
    create_estimate_request(%{name: "Fresh Estimate", status: :new})
    create_estimate_request(%{name: "Review Estimate", status: :in_review})
    create_estimate_request(%{name: "Closed Estimate", status: :closed})

    {:ok, view, _html} = live(conn, ~p"/admin/estimates")

    assert render(view) =~ "Fresh Estimate"
    assert render(view) =~ "Review Estimate"
    assert render(view) =~ "Closed Estimate"

    view
    |> element("button[phx-click='filter_status'][phx-value-status='in_review']")
    |> render_click()

    assert has_element?(view, "#estimates-table tr", "Review Estimate")
    refute has_element?(view, "#estimates-table tr", "Fresh Estimate")
    refute has_element?(view, "#estimates-table tr", "Closed Estimate")

    view
    |> element("button[phx-click='filter_status'][phx-value-status='closed']")
    |> render_click()

    assert has_element?(view, "#estimates-table tr", "Closed Estimate")
    refute has_element?(view, "#estimates-table tr", "Review Estimate")
  end

  test "index deletes an estimate from the stream and database", %{conn: conn} do
    estimate = create_estimate_request(%{name: "Delete Me Estimate"})

    {:ok, view, _html} = live(conn, ~p"/admin/estimates")
    assert has_element?(view, "#estimates-table tr", "Delete Me Estimate")

    view
    |> element("button[phx-click='delete'][phx-value-id='#{estimate.id}']")
    |> render_click()

    refute has_element?(view, "#estimates-table tr", "Delete Me Estimate")
    assert render(view) =~ "Estimate request deleted"

    assert [] ==
             Revstack.Consulting.EstimateRequest
             |> Ash.Query.filter(id == ^estimate.id)
             |> Ash.read!(authorize?: false)
  end

  test "show page renders details and updates status plus internal size", %{conn: conn} do
    estimate =
      create_estimate_request(%{
        name: "Show Estimate",
        company: "Acme Corp",
        project_type: :devops_reliability,
        budget_range: :"50k_plus",
        timeline: :flexible,
        details: "Needs observability, scaling, and release hardening."
      })

    {:ok, view, _html} = live(conn, ~p"/admin/estimates/#{estimate.id}")

    assert render(view) =~ "Show Estimate"
    assert render(view) =~ "Acme Corp"
    assert render(view) =~ "DevOps/Reliability"
    assert render(view) =~ "$50K+"
    assert render(view) =~ "Flexible"
    assert render(view) =~ "Needs observability, scaling, and release hardening."

    view
    |> element("a[href='/admin/estimates/#{estimate.id}/edit']")
    |> render_click()

    assert_patch(view, ~p"/admin/estimates/#{estimate.id}/edit")
    assert has_element?(view, "#estimate-status-form")

    view
    |> form("#estimate-status-form", %{
      "form" => %{"status" => "responded", "internal_size_tag" => "large"}
    })
    |> render_submit()

    assert_patch(view, ~p"/admin/estimates/#{estimate.id}")
    assert render(view) =~ "Estimate request updated"
    assert render(view) =~ "Responded"
    assert render(view) =~ "Large"

    updated_estimate =
      Revstack.Consulting.EstimateRequest |> Ash.get!(estimate.id, authorize?: false)

    assert updated_estimate.status == :responded
    assert updated_estimate.internal_size_tag == :large
  end

  test "show edit mode can be cancelled without persisting changes", %{conn: conn} do
    estimate = create_estimate_request(%{status: :new})

    {:ok, view, _html} = live(conn, ~p"/admin/estimates/#{estimate.id}/edit")
    assert has_element?(view, "#estimate-status-form")

    view
    |> element("button[phx-click='cancel_edit']")
    |> render_click()

    assert_patch(view, ~p"/admin/estimates/#{estimate.id}")
    refute has_element?(view, "#estimate-status-form")

    unchanged_estimate =
      Revstack.Consulting.EstimateRequest |> Ash.get!(estimate.id, authorize?: false)

    assert unchanged_estimate.status == :new
    assert is_nil(unchanged_estimate.internal_size_tag)
  end
end
