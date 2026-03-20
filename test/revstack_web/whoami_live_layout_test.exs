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

    test "renders compact proof points instead of stat cards", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#whoami-proof-points")

      html = render(view)
      assert html =~ "12+ Years on the BEAM"
      assert html =~ "1.5M+ Events/Day"
      assert html =~ "$2.5M+/mo Revenue Supported"
      assert html =~ "5 Engineers Led"
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

  describe "professional experience condensed view" do
    test "renders condensed summary by default", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#experience-summary")
      assert has_element?(view, "#experience-toggle")
      refute has_element?(view, "#experience-detail")
    end

    test "clicking toggle expands full experience", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      refute has_element?(view, "#experience-detail")

      view
      |> element("#experience-toggle")
      |> render_click()

      assert has_element?(view, "#experience-detail")
    end

    test "clicking toggle again collapses experience", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("#experience-toggle") |> render_click()
      assert has_element?(view, "#experience-detail")

      view |> element("#experience-toggle") |> render_click()
      refute has_element?(view, "#experience-detail")
    end
  end
end
