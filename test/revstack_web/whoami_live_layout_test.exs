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

      assert has_element?(view, "#whoami-role-title")
      assert has_element?(view, "#whoami-skill-signature")
    end

    test "renders grouped proof points for strengths and system scale", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#whoami-proof-points")
      assert has_element?(view, "#whoami-proof-points-strengths")
      assert has_element?(view, "#whoami-proof-points-scale")
      assert has_element?(view, "#whoami-proof-points-strengths p", "What I Bring")
      assert has_element?(view, "#whoami-proof-points-scale p", "Systems I've Built")
      assert has_element?(view, "#whoami-proof-points-strengths span", "12+ Years on the BEAM")

      assert has_element?(
               view,
               "#whoami-proof-points-strengths span",
               "5 Engineers Led & Mentored"
             )

      assert has_element?(
               view,
               "#whoami-proof-points-strengths span",
               "End-to-End Platform Ownership"
             )

      assert has_element?(view, "#whoami-proof-points-scale span", "Supported 1.5M+ Events/Day")
      assert has_element?(view, "#whoami-proof-points-scale span", "Powered $2.5M+/mo Revenue")

      assert has_element?(
               view,
               "#whoami-proof-points-scale span",
               "Enabled ~25% Lower Infra Cost"
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

      assert html =~ "Architecture ownership"
      assert html =~ "Scaled platforms"
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

  describe "career highlights section" do
    test "renders curated summary framing and in-section resume CTAs", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#whoami-experience")
      assert has_element?(view, "#career-highlights-subtitle")

      assert has_element?(
               view,
               "#career-highlights-view-resume-link[href='/resume/kyle-neal-resume.pdf'][target='_blank']",
               "View Resume"
             )

      assert has_element?(
               view,
               "#career-highlights-download-resume-link[href='/resume/download/kyle-neal-resume.pdf'][download]",
               "Download Resume"
             )
    end

    test "renders compact highlight cards instead of an expandable resume mirror", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#career-highlight-ionik")
      assert has_element?(view, "#career-highlight-revenuelink")
      assert has_element?(view, "#career-highlight-cgi")
      assert has_element?(view, "#career-highlight-wichita")
      assert has_element?(view, "#career-highlight-tutor")

      refute has_element?(view, "#experience-toggle")
      refute has_element?(view, "#experience-detail")
    end
  end
end
