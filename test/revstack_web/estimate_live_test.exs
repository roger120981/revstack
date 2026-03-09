defmodule RevstackWeb.EstimateLiveTest do
  use RevstackWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  @moduletag capture_log: true

  require Ash.Query

  alias Revstack.Consulting.EstimateRequest

  test "estimate page exposes the broader project type options", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/estimate")

    assert has_element?(view, "#estimate-page-logo[alt='RevenueLink Technologies']")
    assert has_element?(view, "#estimate-intro-copy")
    assert has_element?(view, "#estimate-form option[value='beam_consulting']", "BEAM Consulting")

    assert has_element?(
             view,
             "#estimate-form option[value='phoenix_liveview_application']",
             "Phoenix / LiveView Application"
           )

    assert has_element?(
             view,
             "#estimate-form option[value='custom_web_application']",
             "Custom Web Application"
           )

    assert has_element?(
             view,
             "#estimate-form option[value='distributed_system_architecture']",
             "Distributed System Architecture"
           )

    assert has_element?(
             view,
             "#estimate-form option[value='production_debugging_reliability']",
             "Production Debugging / Reliability"
           )

    assert has_element?(view, "#estimate-form option[value='gaming_pc_build']", "Gaming PC Build")

    assert has_element?(
             view,
             "#estimate-form option[value='small_business_network_setup']",
             "Small Business Network Setup"
           )

    assert has_element?(
             view,
             "#estimate-form option[value='technology_consulting']",
             "Technology Consulting"
           )

    assert has_element?(view, "#estimate-form option[value='other']", "Other")
  end

  test "estimate form accepts one of the new project types", %{conn: conn} do
    email = "estimate-#{System.unique_integer([:positive])}@example.com"

    {:ok, view, _html} = live(conn, ~p"/estimate")

    {:ok, _thanks_view, _html} =
      view
      |> form("#estimate-form", %{
        "form" => %{
          "name" => "Taylor Engineer",
          "email" => email,
          "company" => "Revstack Prospect",
          "project_type" => "beam_consulting",
          "budget_range" => "15k_50k",
          "timeline" => "1_2_months",
          "summary" =>
            "We need a BEAM architecture review and production guidance for a system that has started showing reliability issues.",
          "details" => "Looking for architecture and stabilization support.",
          "source" => "website"
        }
      })
      |> render_submit()
      |> follow_redirect(conn, ~p"/thanks")

    estimate =
      EstimateRequest
      |> Ash.Query.filter(email == ^email)
      |> Ash.read_one!(authorize?: false)

    assert estimate.project_type == :beam_consulting
    assert estimate.company == "Revstack Prospect"
  end
end
