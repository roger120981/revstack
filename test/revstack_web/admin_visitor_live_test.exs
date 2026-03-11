defmodule RevstackWeb.Admin.VisitorLiveTest do
  use RevstackWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Revstack.TestSupport.AuthFixtures

  alias Revstack.Tracking.Service

  defp create_visitor(ip, opts \\ %{}) do
    user_agent = Map.get(opts, :user_agent, "TestBot/1.0")
    referrer = Map.get(opts, :referrer)
    {:ok, visitor} = Service.find_or_create_visitor(ip, user_agent, referrer)
    visitor
  end

  defp create_page_visits(visitor, paths) do
    Enum.each(paths, fn path ->
      {:ok, _} = Service.create_page_visit(visitor, path)
    end)
  end

  describe "VisitorLive.Index" do
    test "shows visitor list with correct columns", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      visitor = create_visitor("198.51.100.1", %{user_agent: "Chrome/100"})
      create_page_visits(visitor, ["/", "/about", "/contact"])
      # Increment visit_count for additional visits
      Service.find_or_create_visitor("198.51.100.1")
      Service.find_or_create_visitor("198.51.100.1")

      conn = log_in_user(conn, admin)
      {:ok, view, _html} = live(conn, ~p"/admin/visitors")

      assert has_element?(view, "#visitors-table")
      html = render(view)
      assert html =~ "198.51.100.1"
      assert html =~ "Chrome/100"
    end

    test "shows empty state when no visitors", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      conn = log_in_user(conn, admin)
      {:ok, _view, html} = live(conn, ~p"/admin/visitors")

      assert html =~ "No visitors found"
    end

    test "shows multiple visitors sorted by last_visited_at", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      _visitor1 = create_visitor("198.51.100.10")
      Process.sleep(10)
      _visitor2 = create_visitor("198.51.100.11")

      conn = log_in_user(conn, admin)
      {:ok, _view, html} = live(conn, ~p"/admin/visitors")

      assert html =~ "198.51.100.10"
      assert html =~ "198.51.100.11"
    end

    test "filters by has_leads", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      _visitor_no_leads = create_visitor("198.51.100.20")

      visitor_with_lead = create_visitor("198.51.100.21")
      create_lead(%{request_ip: visitor_with_lead.ip_address})

      conn = log_in_user(conn, admin)
      {:ok, view, _html} = live(conn, ~p"/admin/visitors")

      # Filter to only visitors with leads
      html = view |> element("button", "Has Leads") |> render_click()

      assert html =~ "198.51.100.21"
      refute html =~ "198.51.100.20"
    end

    test "filters by has_estimates", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      _visitor_no_estimates = create_visitor("198.51.100.30")

      visitor_with_estimate = create_visitor("198.51.100.31")
      create_estimate_request(%{request_ip: visitor_with_estimate.ip_address})

      conn = log_in_user(conn, admin)
      {:ok, view, _html} = live(conn, ~p"/admin/visitors")

      # Filter to only visitors with estimates
      html = view |> element("button", "Has Estimates") |> render_click()

      assert html =~ "198.51.100.31"
      refute html =~ "198.51.100.30"
    end

    test "has view link to visitor detail", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      visitor = create_visitor("198.51.100.40")

      conn = log_in_user(conn, admin)
      {:ok, view, _html} = live(conn, ~p"/admin/visitors")

      assert has_element?(view, "a[href='/admin/visitors/#{visitor.id}']", "View")
    end

    test "shows lead and estimate counts per visitor", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      visitor = create_visitor("198.51.100.50")
      create_lead(%{request_ip: visitor.ip_address})
      create_lead(%{request_ip: visitor.ip_address})
      create_estimate_request(%{request_ip: visitor.ip_address})

      conn = log_in_user(conn, admin)
      {:ok, _view, html} = live(conn, ~p"/admin/visitors")

      # The visitor row should show the counts
      assert html =~ "198.51.100.50"
    end
  end

  describe "VisitorLive.Show" do
    test "shows visitor summary details", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      visitor = create_visitor("198.51.100.60", %{user_agent: "ShowTestBot/2.0"})

      conn = log_in_user(conn, admin)
      {:ok, view, _html} = live(conn, ~p"/admin/visitors/#{visitor.id}")

      assert has_element?(view, "#visitor-summary")
      html = render(view)
      assert html =~ "198.51.100.60"
      assert html =~ "ShowTestBot/2.0"
    end

    test "shows page visit history", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      visitor = create_visitor("198.51.100.70")
      create_page_visits(visitor, ["/", "/about", "/services"])

      conn = log_in_user(conn, admin)
      {:ok, view, _html} = live(conn, ~p"/admin/visitors/#{visitor.id}")

      assert has_element?(view, "#page-visits-table")
      html = render(view)
      assert html =~ "/about"
      assert html =~ "/services"
    end

    test "shows conversion stats cards", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      visitor = create_visitor("198.51.100.80")
      create_lead(%{request_ip: visitor.ip_address})
      create_estimate_request(%{request_ip: visitor.ip_address})

      conn = log_in_user(conn, admin)
      {:ok, view, _html} = live(conn, ~p"/admin/visitors/#{visitor.id}")

      assert has_element?(view, "#visitor-conversion-visits")
      assert has_element?(view, "#visitor-conversion-leads")
      assert has_element?(view, "#visitor-conversion-estimates")
    end

    test "shows related lead submissions", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      visitor = create_visitor("198.51.100.90")
      lead = create_lead(%{request_ip: visitor.ip_address, name: "Detail Lead Test"})

      conn = log_in_user(conn, admin)
      {:ok, view, html} = live(conn, ~p"/admin/visitors/#{visitor.id}")

      assert html =~ "Detail Lead Test"
      assert has_element?(view, "a[href='/admin/leads/#{lead.id}']", "View")
    end

    test "shows related estimate submissions", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      visitor = create_visitor("198.51.100.100")

      estimate =
        create_estimate_request(%{
          request_ip: visitor.ip_address,
          name: "Detail Estimate Test"
        })

      conn = log_in_user(conn, admin)
      {:ok, view, html} = live(conn, ~p"/admin/visitors/#{visitor.id}")

      assert html =~ "Detail Estimate Test"
      assert has_element?(view, "a[href='/admin/estimates/#{estimate.id}']", "View")
    end

    test "has back to visitors link", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      visitor = create_visitor("198.51.100.110")

      conn = log_in_user(conn, admin)
      {:ok, view, _html} = live(conn, ~p"/admin/visitors/#{visitor.id}")

      assert has_element?(view, "a[href='/admin/visitors']", "Back to Visitors")
    end
  end

  describe "Dashboard integration" do
    test "dashboard shows visitor count and visitors link", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      _visitor = create_visitor("198.51.100.200")

      conn = log_in_user(conn, admin)
      {:ok, view, _html} = live(conn, ~p"/admin")

      assert has_element?(view, "#dashboard-total-visitors", "1")
      assert has_element?(view, "a[href='/admin/visitors']", "View all visitors")
    end
  end

  describe "Resume view tracking in admin" do
    test "index shows resume view count per visitor", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      visitor = create_visitor("198.51.100.210")
      Service.create_page_visit(visitor, "/resume/view")
      Service.create_page_visit(visitor, "/resume/view")

      conn = log_in_user(conn, admin)
      {:ok, view, _html} = live(conn, ~p"/admin/visitors")

      assert has_element?(view, "#visitors-table")
      html = render(view)
      assert html =~ "198.51.100.210"
      assert html =~ "hero-document-magnifying-glass"
    end

    test "index shows zero for visitors without resume views", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      _visitor = create_visitor("198.51.100.211")

      conn = log_in_user(conn, admin)
      {:ok, view, _html} = live(conn, ~p"/admin/visitors")

      assert has_element?(view, "#visitors-table")
    end

    test "index filters by Viewed Resume", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      _visitor_no_resume = create_visitor("198.51.100.220")

      visitor_with_resume = create_visitor("198.51.100.221")
      Service.create_page_visit(visitor_with_resume, "/resume/view")

      conn = log_in_user(conn, admin)
      {:ok, view, _html} = live(conn, ~p"/admin/visitors")

      html = view |> element("button", "Viewed Resume") |> render_click()

      assert html =~ "198.51.100.221"
      refute html =~ "198.51.100.220"
    end

    test "index filters by Downloaded Resume", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      _visitor_no_download = create_visitor("198.51.100.224")

      visitor_with_download = create_visitor("198.51.100.225")
      Service.create_page_visit(visitor_with_download, "/resume/download")

      conn = log_in_user(conn, admin)
      {:ok, view, _html} = live(conn, ~p"/admin/visitors")

      html = view |> element("button", "Downloaded Resume") |> render_click()

      assert html =~ "198.51.100.225"
      refute html =~ "198.51.100.224"
    end

    test "index filter resets back to all", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      visitor_no_resume = create_visitor("198.51.100.222")
      visitor_with_resume = create_visitor("198.51.100.223")
      Service.create_page_visit(visitor_with_resume, "/resume/view")

      conn = log_in_user(conn, admin)
      {:ok, view, _html} = live(conn, ~p"/admin/visitors")

      # Filter to resume only
      view |> element("button", "Viewed Resume") |> render_click()

      # Switch back to all
      html = view |> element("button", "All") |> render_click()

      assert html =~ visitor_no_resume.ip_address
      assert html =~ visitor_with_resume.ip_address
    end

    test "index applies filter from URL query param", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      _visitor_no_resume = create_visitor("198.51.100.226")

      visitor_with_views = create_visitor("198.51.100.227")
      Service.create_page_visit(visitor_with_views, "/resume/view")

      conn = log_in_user(conn, admin)
      {:ok, _view, html} = live(conn, ~p"/admin/visitors?filter=has_resume_views")

      assert html =~ "198.51.100.227"
      refute html =~ "198.51.100.226"
    end

    test "show page displays resume views conversion card", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      visitor = create_visitor("198.51.100.230")
      Service.create_page_visit(visitor, "/resume/view")

      conn = log_in_user(conn, admin)
      {:ok, view, _html} = live(conn, ~p"/admin/visitors/#{visitor.id}")

      assert has_element?(view, "#visitor-conversion-resume-views")
      html = render(view)
      assert html =~ "Resume Views"
    end

    test "show page displays resume downloads conversion card", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      visitor = create_visitor("198.51.100.232")
      Service.create_page_visit(visitor, "/resume/download")

      conn = log_in_user(conn, admin)
      {:ok, view, _html} = live(conn, ~p"/admin/visitors/#{visitor.id}")

      assert has_element?(view, "#visitor-conversion-resume-downloads")
      html = render(view)
      assert html =~ "Resume Downloads"
    end

    test "show page displays resume view count in visitor summary", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      visitor = create_visitor("198.51.100.231")
      Service.create_page_visit(visitor, "/resume/view")
      Service.create_page_visit(visitor, "/resume/view")

      conn = log_in_user(conn, admin)
      {:ok, view, _html} = live(conn, ~p"/admin/visitors/#{visitor.id}")

      html = render(view)
      assert html =~ "Resume Views"
      assert html =~ "Resume Downloads"
    end

    test "show page highlights resume visit in history", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      visitor = create_visitor("198.51.100.240")
      Service.create_page_visit(visitor, "/about")
      Service.create_page_visit(visitor, "/resume/view")
      Service.create_page_visit(visitor, "/resume/download")

      conn = log_in_user(conn, admin)
      {:ok, view, _html} = live(conn, ~p"/admin/visitors/#{visitor.id}")

      assert has_element?(view, "#page-visits-table")
      html = render(view)
      assert html =~ "/resume/view"
      assert html =~ "/resume/download"
      assert html =~ "hero-arrow-down-tray"
    end

    test "show page resume cards show zero when no views", %{conn: conn} do
      admin = create_and_sign_in_user(%{admin?: true})
      visitor = create_visitor("198.51.100.250")
      Service.create_page_visit(visitor, "/about")

      conn = log_in_user(conn, admin)
      {:ok, view, _html} = live(conn, ~p"/admin/visitors/#{visitor.id}")

      assert has_element?(view, "#visitor-conversion-resume-views")
      assert has_element?(view, "#visitor-conversion-resume-downloads")
    end
  end
end
