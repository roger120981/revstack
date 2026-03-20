defmodule RevstackWeb.WhoamiLiveNavigationMenuTest do
  use RevstackWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "section navigation menu" do
    test "always-visible toggle icon renders while menu is hidden by default", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/whoami")

      assert has_element?(view, "#section-nav-toggle[aria-label='Toggle section navigation']")
      assert has_element?(view, "#header-brand-row #section-nav-toggle")
      refute has_element?(view, "#section-nav-panel")
    end

    test "toggle click opens and closes menu panel", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/whoami")

      view
      |> element("#section-nav-toggle")
      |> render_click()

      assert has_element?(view, "#section-nav-panel")

      view
      |> element("#section-nav-toggle")
      |> render_click()

      refute has_element?(view, "#section-nav-panel")
    end

    test "menu exposes jump links for key section anchors", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/whoami")

      view
      |> element("#section-nav-toggle")
      |> render_click()

      assert has_element?(view, "#section-nav-link-whoami-hero[href='#whoami-hero']", "Hero")

      assert has_element?(
               view,
               "#section-nav-link-whoami-portfolio[href='#whoami-portfolio']",
               "Career Portfolio"
             )

      assert has_element?(
               view,
               "#section-nav-link-whoami-experience[href='#whoami-experience']",
               "Professional Experience"
             )

      assert has_element?(
               view,
               "#section-nav-link-leadership-teamwork[href='#leadership-teamwork']",
               "Leadership & Teamwork"
             )

      assert has_element?(
               view,
               "#section-nav-link-live-projects[href='#live-projects']",
               "Independent Projects"
             )

      assert has_element?(
               view,
               "#section-nav-link-whoami-source[href='#whoami-source']",
               "Source Code"
             )
    end

    test "close button hides panel without removing the toggle icon", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/whoami")

      view
      |> element("#section-nav-toggle")
      |> render_click()

      assert has_element?(view, "#section-nav-panel")

      view
      |> element("#section-nav-close")
      |> render_click()

      refute has_element?(view, "#section-nav-panel")
      assert has_element?(view, "#section-nav-toggle")
    end
  end
end
