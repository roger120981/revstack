defmodule RevstackWeb.ServicesLiveTest do
  use RevstackWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "services page presents the three service paths and typical engagements", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/services")

    assert has_element?(view, "#services-page-logo[alt='RevenueLink Technologies']")
    assert has_element?(view, "#services-overview")
    assert has_element?(view, "#services-overview-beam", "Distributed Systems & BEAM Consulting")
    assert has_element?(view, "#services-overview-web", "Custom Web Applications / Websites")
    assert has_element?(view, "#services-overview-local", "Local Technology Services")
    assert has_element?(view, "#services-distributed-systems")
    assert has_element?(view, "#services-custom-web-applications")
    assert has_element?(view, "#services-local-technology-services")

    assert has_element?(
             view,
             "#service-beam-architecture",
             "Erlang / OTP Architecture Consulting"
           )

    assert has_element?(view, "#service-liveview-apps", "Phoenix / LiveView Applications")
    assert has_element?(view, "#service-gaming-pc-builds", "Custom Gaming PC Builds")
    assert has_element?(view, "#service-home-tech-support", "In-Home Technology Troubleshooting")
    assert render(view) =~ "custom websites"

    assert has_element?(view, "#engagement-models", "Engagement Models")
    assert has_element?(view, "#typical-engagements", "Typical Engagements")
    assert has_element?(view, "#engagement-beam-system-review", "BEAM System Review")
    assert has_element?(view, "#engagement-custom-website", "Custom Website or Product Site")
    assert has_element?(view, "#engagement-gaming-pc-build", "Custom Gaming PC Build")

    assert has_element?(view, "#request-estimate-cta", "Request an Estimate")
    assert has_element?(view, "#services-profile-cta", "View Profile")
  end
end
