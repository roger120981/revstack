defmodule RevstackWeb.NavigationActiveStateTest do
  use RevstackWeb.ConnCase

  import Phoenix.LiveViewTest

  describe "navigation active state highlighting" do
    test "highlights Profile menu when on /whoami page", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/whoami")

      # Desktop navigation - Profile should have active styling
      assert view
             |> element("#nav-home")
             |> render() =~ "bg-primary/10"

      assert view
             |> element("#nav-home")
             |> render() =~ "text-primary"

      # Desktop navigation - other links should not have active styling
      refute view
             |> element("#nav-services")
             |> render() =~ "bg-primary/10"

      refute view
             |> element("#nav-contact")
             |> render() =~ "bg-primary/10"
    end

    test "highlights Services menu when on /services page", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/services")

      # Desktop navigation - Services should have active styling
      assert view
             |> element("#nav-services")
             |> render() =~ "bg-primary/10"

      assert view
             |> element("#nav-services")
             |> render() =~ "text-primary"

      # Desktop navigation - other links should not have active styling
      refute view
             |> element("#nav-home")
             |> render() =~ "text-primary"

      refute view
             |> element("#nav-contact")
             |> render() =~ "bg-primary/10"
    end

    test "highlights Estimate menu when on /estimate page", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/estimate")

      # Desktop navigation - Estimate should have active styling
      assert view
             |> element("#nav-estimate")
             |> render() =~ "bg-primary/10"

      assert view
             |> element("#nav-estimate")
             |> render() =~ "text-primary"

      # Desktop navigation - other links should not have active styling
      refute view
             |> element("#nav-home")
             |> render() =~ "text-primary"

      refute view
             |> element("#nav-services")
             |> render() =~ "bg-primary/10"
    end

    test "highlights Contact menu when on /contact page", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/contact")

      # Desktop navigation - Contact should have active styling
      assert view
             |> element("#nav-contact")
             |> render() =~ "bg-primary/10"

      assert view
             |> element("#nav-contact")
             |> render() =~ "text-primary"

      # Desktop navigation - other links should not have active styling
      refute view
             |> element("#nav-home")
             |> render() =~ "text-primary"

      refute view
             |> element("#nav-services")
             |> render() =~ "bg-primary/10"
    end

    test "mobile navigation highlights active menu on /contact page", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/contact")

      # Mobile navigation - Contact should have active styling
      assert view
             |> element("#mobile-nav-contact")
             |> render() =~ "bg-primary/10"

      assert view
             |> element("#mobile-nav-contact")
             |> render() =~ "text-primary"

      # Mobile navigation - other links should not have active styling
      refute view
             |> element("#mobile-nav-home")
             |> render() =~ "text-primary"

      refute view
             |> element("#mobile-nav-services")
             |> render() =~ "bg-primary/10"
    end

    test "mobile navigation highlights active menu on /services page", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/services")

      # Mobile navigation - Services should have active styling
      assert view
             |> element("#mobile-nav-services")
             |> render() =~ "bg-primary/10"

      assert view
             |> element("#mobile-nav-services")
             |> render() =~ "text-primary"

      # Mobile navigation - other links should not have active styling
      refute view
             |> element("#mobile-nav-home")
             |> render() =~ "text-primary"
    end
  end
end
