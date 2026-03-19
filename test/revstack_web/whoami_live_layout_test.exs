defmodule RevstackWeb.WhoamiLiveLayoutTest do
  use RevstackWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "hero section" do
    test "renders hero section with button elements", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#view-resume-link")
      assert has_element?(view, "#download-resume-link")
      assert has_element?(view, "#hero-contact-link")
    end

    test "contact me button is separate from resume buttons", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      document = LazyHTML.from_fragment(html)
      contact_link = LazyHTML.filter(document, "#hero-contact-link")

      refute contact_link == []
    end

    test "renders role title and skill signature", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#whoami-role-title", "Lead Distributed Systems Engineer")
      assert has_element?(view, "#whoami-skill-signature", "1.5M+ events/day")
    end

    test "hero surfaces recruiter-facing fit and proof points without a stat grid", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#whoami-role-fit", "Staff Backend Engineer")
      assert has_element?(view, "#whoami-role-fit", "Technical Lead Who Still Codes")
      assert has_element?(view, "#whoami-proof-points", "1.5M+")

      assert has_element?(
               view,
               "#whoami-proof-points",
               "events/day processed by systems I've built"
             )

      assert has_element?(view, "#whoami-proof-points", "~25%")

      assert has_element?(
               view,
               "#whoami-proof-points",
               "infrastructure cost reduction through workflow and scaling improvements"
             )
    end
  end

  describe "combined leadership and teamwork section" do
    test "renders the combined leadership-teamwork section", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#leadership-teamwork")
    end

    test "contains teamwork collaboration cards", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#teamwork-poland")
      assert has_element?(view, "#teamwork-ph-infra")
    end

    test "renders leadership items within the combined section", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Long-term ownership of revenue-critical backend platforms"
      assert html =~ "Reduced infrastructure operating costs by ~25%"
      assert html =~ "leadership-teamwork"
    end
  end

  describe "section card styling" do
    test "page uses a shared vertical spacing wrapper between sections", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#whoami-sections.space-y-6.sm\\:space-y-8.lg\\:space-y-10")
    end

    test "sections use section-card class for consistent styling", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      # Verify key sections have the section-card class by checking specific ones
      assert has_element?(view, "#live-projects.section-card")
      assert has_element?(view, "#leadership-teamwork.section-card")
    end

    test "live projects section has section-card styling", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      document = LazyHTML.from_fragment(html)
      live_projects = LazyHTML.filter(document, "#live-projects.section-card")

      refute live_projects == []
    end

    test "leadership-teamwork section has section-card styling", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      document = LazyHTML.from_fragment(html)
      section = LazyHTML.filter(document, "#leadership-teamwork.section-card")

      refute section == []
    end
  end
end
