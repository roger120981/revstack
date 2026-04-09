defmodule RevstackWeb.WhoamiLiveProjectsTest do
  use RevstackWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  @moduletag capture_log: true

  @active_gallery_image_count 7
  @marketmate_gallery_image_count 6

  describe "live projects section" do
    test "renders completed projects first, followed by in-progress projects", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "#live-projects")
      assert has_element?(view, "#live-projects-completed")
      assert has_element?(view, "#live-projects-in-progress")
      assert has_element?(view, "#live-projects-in-progress-badge", "In Progress")
      assert has_element?(view, "#project-marketmate")
      assert has_element?(view, "#project-handyman")
      assert has_element?(view, "#project-admin")
      # assert has_element?(view, "#project-revenuelink")
      assert has_element?(view, "#live-projects p", "Click a project to explore")

      html = render(view)
      assert String.contains?(html, "Completed Projects")
      assert String.contains?(html, "In Progress Projects")
      completed_position = :binary.match(html, "live-projects-completed")
      in_progress_position = :binary.match(html, "live-projects-in-progress")

      assert completed_position != :nomatch
      assert in_progress_position != :nomatch
      assert elem(completed_position, 0) < elem(in_progress_position, 0)
    end

    test "marketmate card uses the dashboard preview image", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      document = LazyHTML.from_fragment(html)
      marketmate = LazyHTML.query_by_id(document, "project-marketmate")
      tree = LazyHTML.to_tree(marketmate, sort_attributes: true, skip_whitespace_nodes: true)

      assert has_src_containing?(tree, "market_mate/dashboard.png")
    end

    test "hardcore handyman card uses local preview image", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      document = LazyHTML.from_fragment(html)
      handyman = LazyHTML.query_by_id(document, "project-handyman")
      tree = LazyHTML.to_tree(handyman, sort_attributes: true, skip_whitespace_nodes: true)

      assert has_src_containing?(tree, "hardcorehandyman_preview")
    end

    test "admin panel card uses local dashboard preview image", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      document = LazyHTML.from_fragment(html)
      admin = LazyHTML.query_by_id(document, "project-admin")
      tree = LazyHTML.to_tree(admin, sort_attributes: true, skip_whitespace_nodes: true)

      assert has_src_containing?(tree, "admin_dashboard")
    end

    test "project cards display tech badges", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Elixir"
      assert html =~ "Phoenix"
      assert html =~ "LiveView"
    end

    test "hardcore handyman card links to external site", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      document = LazyHTML.from_fragment(render(view))
      handyman = LazyHTML.query_by_id(document, "project-handyman")
      tree = LazyHTML.to_tree(handyman, sort_attributes: true, skip_whitespace_nodes: true)

      assert has_href_containing?(tree, "hardcorehandyman.fly.dev")
    end

    test "admin panel card is a button with on_click event", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "button#project-admin[phx-click='open_admin_gallery']")
    end

    test "marketmate card is a button without a duplicate card badge", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(
               view,
               "button#project-marketmate[phx-click='open_marketmate_gallery']"
             )

      refute has_element?(view, "#project-marketmate-badge")
    end

    test "admin panel card shows the GitHub URL in the card preview", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(
               view,
               "button#project-admin p",
               "https://github.com/kyle-neal/revstack"
             )
    end
  end

  describe "marketmate gallery modal" do
    test "modal is not rendered on initial page load", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      refute has_element?(view, "#marketmate-gallery-modal")
    end

    test "clicking marketmate opens the gallery modal", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> element("button#project-marketmate")
      |> render_click()

      assert has_element?(view, "#marketmate-gallery-modal")
    end

    test "modal shows the first walkthrough slide and source link by default", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("button#project-marketmate") |> render_click()

      html = render(view)
      assert html =~ "1 of #{@marketmate_gallery_image_count}"
      assert html =~ "Live Portfolio Updates"
      assert html =~ "The value is immediate market awareness delivered in real time"

      assert has_element?(
               view,
               "#marketmate-gallery-source-link[href='https://github.com/kyle-neal/market_mate'][target='_blank'][rel='noopener noreferrer']",
               "View Source Code on GitHub"
             )
    end

    test "modal renders the first walkthrough slide as an mp4 video", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("button#project-marketmate") |> render_click()

      document = LazyHTML.from_fragment(render(view))
      modal = LazyHTML.query_by_id(document, "marketmate-gallery-modal")
      tree = LazyHTML.to_tree(modal, sort_attributes: true, skip_whitespace_nodes: true)

      assert has_tag_with_attribute?(tree, "video", "autoplay")
      assert has_tag_with_src_containing?(tree, "source", "market_mate/live_dash.mp4")
    end

    test "modal has LockBodyScroll phx-hook", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("button#project-marketmate") |> render_click()

      html = render(view)
      document = LazyHTML.from_fragment(html)
      modal = LazyHTML.query_by_id(document, "marketmate-gallery-modal")
      tree = LazyHTML.to_tree(modal, sort_attributes: true, skip_whitespace_nodes: true)

      assert has_hook_attribute?(tree, "LockBodyScroll")
    end

    test "next button advances to the architecture slide", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("button#project-marketmate") |> render_click()
      view |> element("#marketmate-gallery-next") |> render_click()

      html = render(view)
      assert html =~ "2 of #{@marketmate_gallery_image_count}"
      assert html =~ "System Architecture"
      assert html =~ "MMEX"
      assert html =~ "MMERL"
      assert html =~ "The architecture slide shows deliberate system boundaries"
    end

    test "previous button returns to the prior slide", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("button#project-marketmate") |> render_click()
      view |> element("#marketmate-gallery-next") |> render_click()
      view |> element("#marketmate-gallery-prev") |> render_click()

      html = render(view)
      assert html =~ "1 of #{@marketmate_gallery_image_count}"
      assert html =~ "Live Portfolio Updates"
    end

    test "thumbnail selection jumps to the selected walkthrough item", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("button#project-marketmate") |> render_click()

      view
      |> element("#marketmate-gallery-thumb-5")
      |> render_click()

      html = render(view)
      assert html =~ "6 of #{@marketmate_gallery_image_count}"
      assert html =~ "Product Vision"
      assert html =~ "intelligent personal financial advisor"
      assert html =~ "The vision slide anchors the entire walkthrough"
    end

    test "close button dismisses the modal", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("button#project-marketmate") |> render_click()
      assert has_element?(view, "#marketmate-gallery-modal")

      view |> element("#close-marketmate-gallery") |> render_click()
      refute has_element?(view, "#marketmate-gallery-modal")
    end

    test "backdrop click closes the modal", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("button#project-marketmate") |> render_click()
      assert has_element?(view, "#marketmate-gallery-modal")

      html = render(view)
      document = LazyHTML.from_fragment(html)
      modal = LazyHTML.query_by_id(document, "marketmate-gallery-modal")
      tree = LazyHTML.to_tree(modal, sort_attributes: true, skip_whitespace_nodes: true)

      assert has_backdrop_close?(tree, "close_marketmate_gallery")
    end

    test "previous button is hidden on the first slide and next button is hidden on the last slide",
         %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("button#project-marketmate") |> render_click()

      refute has_element?(view, "#marketmate-gallery-prev")
      assert has_element?(view, "#marketmate-gallery-next")

      view
      |> element("#marketmate-gallery-thumb-5")
      |> render_click()

      assert has_element?(view, "#marketmate-gallery-prev")
      refute has_element?(view, "#marketmate-gallery-next")
    end
  end

  describe "leadership and teamwork section" do
    test "renders the leadership and teamwork collaboration narrative", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/whoami")

      assert has_element?(view, "#leadership-teamwork")
      assert has_element?(view, "#teamwork-poland")
      assert has_element?(view, "#teamwork-ph-infra")

      html = render(view)

      assert html =~ "5 backend"
      assert html =~ "3 DevOps engineers"
      assert html =~ "sole owner"
      assert html =~ "self-managed unit"
    end
  end

  describe "career highlights emphasis" do
    test "keeps the Ionik role as the dominant recruiter-facing summary", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/whoami")

      assert has_element?(
               view,
               "#career-highlight-ionik li",
               "Architected, built, and ultimately owned a revenue-critical affiliate network platform in Erlang/OTP"
             )

      assert has_element?(
               view,
               "#career-highlight-ionik li",
               "Built NetAdmin in Elixir, Phoenix LiveView, and Ash Framework as the internal platform"
             )

      assert has_element?(
               view,
               "#career-highlight-ionik li",
               "Cassandra, RabbitMQ, Elasticsearch/OpenSearch, PostgreSQL, and Spark on AWS EMR"
             )
    end

    test "shows entrepreneurial and real-world demand proof in the RevenueLink role", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, ~p"/whoami")

      assert has_element?(
               view,
               "#career-highlight-revenuelink li",
               "Founded RevenueLink as a vehicle for independent product work, consulting, and hands-on experimentation"
             )

      assert has_element?(
               view,
               "#career-highlight-revenuelink li",
               "the platform generated more inbound demand than the business could operationally support"
             )
    end

    test "includes the tutor role alongside the other supporting experience cards", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/whoami")

      assert has_element?(view, "#career-highlight-tutor")

      assert has_element?(
               view,
               "#career-highlight-tutor li",
               "Provided one-on-one computer science tutoring"
             )
    end
  end

  describe "hero contact links" do
    test "renders personal and business email links plus the resume view and download links", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, ~p"/whoami")

      assert has_element?(
               view,
               "#whoami-github-link[href='https://github.com/kyle-neal']",
               "GitHub"
             )

      assert has_element?(
               view,
               "#personal-email-link[href='mailto:nealkyle5@gmail.com']",
               "nealkyle5@gmail.com"
             )

      assert has_element?(
               view,
               "#view-resume-link[href='/resume/kyle-neal-resume.pdf'][target='_blank']",
               "View Resume"
             )

      assert has_element?(
               view,
               "#download-resume-link[href='/resume/download/kyle-neal-resume.pdf'][download][title=\"Download Kyle's Resume\"]"
             )
    end

    test "view resume is served through a tracked controller route", %{conn: conn} do
      conn = get(conn, "/resume/kyle-neal-resume.pdf")
      assert conn.status == 200
      assert {"content-type", "application/pdf"} in conn.resp_headers
    end

    test "download resume is served through a tracked controller route", %{conn: conn} do
      conn = get(conn, "/resume/download/kyle-neal-resume.pdf")
      assert conn.status == 200
      assert {"content-type", "application/pdf"} in conn.resp_headers
    end

    test "whoami page keeps recruiter-facing badge emphasis on live project tech tags", %{
      conn: conn
    } do
      {:ok, view, _html} = live(conn, ~p"/whoami")

      refute has_element?(view, "#whoami-role-title span.skill-emphasis-primary")
      refute has_element?(view, "#whoami-skill-signature span.skill-emphasis-primary")
      refute has_element?(view, "#whoami-skill-signature span.skill-emphasis-subtle")

      assert has_element?(view, "#project-admin span.skill-badge-primary", "Elixir")
      assert has_element?(view, "#project-admin span.skill-badge-subtle", "Postgres")
    end
  end

  describe "admin gallery modal" do
    test "modal is not rendered on initial page load", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      refute has_element?(view, "#admin-gallery-modal")
    end

    test "clicking admin card opens the gallery modal", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> element("button#project-admin")
      |> render_click()

      assert has_element?(view, "#admin-gallery-modal")
    end

    test "modal displays the first image (admin dashboard) by default", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("button#project-admin") |> render_click()

      html = render(view)
      document = LazyHTML.from_fragment(html)
      modal = LazyHTML.query_by_id(document, "admin-gallery-modal")
      tree = LazyHTML.to_tree(modal, sort_attributes: true, skip_whitespace_nodes: true)

      assert has_src_containing?(tree, "admin_dashboard")
      assert html =~ "1 of #{@active_gallery_image_count}"
      assert html =~ "Admin Dashboard"
    end

    test "modal has LockBodyScroll phx-hook", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("button#project-admin") |> render_click()

      html = render(view)
      document = LazyHTML.from_fragment(html)
      modal = LazyHTML.query_by_id(document, "admin-gallery-modal")
      tree = LazyHTML.to_tree(modal, sort_attributes: true, skip_whitespace_nodes: true)

      assert has_hook_attribute?(tree, "LockBodyScroll")
    end

    test "next button advances to the next image", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("button#project-admin") |> render_click()

      view |> element("#admin-gallery-next") |> render_click()

      html = render(view)
      assert html =~ "2 of #{@active_gallery_image_count}"
      assert html =~ "Lead Listing"
    end

    test "previous button goes back to prior image", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("button#project-admin") |> render_click()

      # Go forward twice
      view |> element("#admin-gallery-next") |> render_click()
      view |> element("#admin-gallery-next") |> render_click()

      html = render(view)
      assert html =~ "3 of #{@active_gallery_image_count}"
      assert html =~ "Lead Detail View"

      # Go back
      view |> element("#admin-gallery-prev") |> render_click()

      html = render(view)
      assert html =~ "2 of #{@active_gallery_image_count}"
      assert html =~ "Lead Listing"
    end

    test "thumbnail selection jumps to the selected image", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("button#project-admin") |> render_click()

      # Click on thumbnail index 6 (Visitor Detail View - the last image)
      view
      |> element("button[phx-click='admin_gallery_select'][phx-value-index='6']")
      |> render_click()

      html = render(view)
      assert html =~ "7 of #{@active_gallery_image_count}"
      assert html =~ "Visitor Detail View"
    end

    test "close button dismisses the modal", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("button#project-admin") |> render_click()
      assert has_element?(view, "#admin-gallery-modal")

      view |> element("#close-admin-gallery") |> render_click()
      refute has_element?(view, "#admin-gallery-modal")
    end

    test "backdrop click closes the modal", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("button#project-admin") |> render_click()
      assert has_element?(view, "#admin-gallery-modal")

      html = render(view)
      document = LazyHTML.from_fragment(html)
      modal = LazyHTML.query_by_id(document, "admin-gallery-modal")
      tree = LazyHTML.to_tree(modal, sort_attributes: true, skip_whitespace_nodes: true)

      assert has_backdrop_close?(tree, "close_admin_gallery")
    end

    test "modal shows thumbnail strip with all images", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("button#project-admin") |> render_click()

      html = render(view)

      # Count occurrences of the thumbnail select event
      count =
        Regex.scan(~r/phx-click="admin_gallery_select"/, html) |> length()

      assert count == @active_gallery_image_count
    end

    test "previous button not shown on first image", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("button#project-admin") |> render_click()

      refute has_element?(view, "#admin-gallery-prev")
      assert has_element?(view, "#admin-gallery-next")
    end

    test "next button not shown on last image", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view |> element("button#project-admin") |> render_click()

      view
      |> element("button[phx-click='admin_gallery_select'][phx-value-index='6']")
      |> render_click()

      html = render(view)
      assert html =~ "7 of #{@active_gallery_image_count}"
      assert has_element?(view, "#admin-gallery-prev")
      refute has_element?(view, "#admin-gallery-next")
    end
  end

  # Helper to check if any element in the tree has a src attribute containing a substring
  defp has_src_containing?(tree, substring) when is_list(tree) do
    Enum.any?(tree, &has_src_containing?(&1, substring))
  end

  defp has_src_containing?({_tag, attrs, children}, substring) do
    src_match =
      Enum.any?(attrs, fn
        {"src", src} -> String.contains?(src, substring)
        _ -> false
      end)

    src_match or has_src_containing?(children, substring)
  end

  defp has_src_containing?(_other, _substring), do: false

  # Helper to check if any element has an href containing a substring
  defp has_href_containing?(tree, substring) when is_list(tree) do
    Enum.any?(tree, &has_href_containing?(&1, substring))
  end

  defp has_href_containing?({_tag, attrs, children}, substring) do
    href_match =
      Enum.any?(attrs, fn
        {"href", href} -> String.contains?(href, substring)
        _ -> false
      end)

    href_match or has_href_containing?(children, substring)
  end

  defp has_href_containing?(_other, _substring), do: false

  defp has_hook_attribute?(tree, hook_name) do
    case tree do
      [{_tag, attrs, _children}] ->
        Enum.any?(attrs, fn
          {"phx-hook", ^hook_name} -> true
          _ -> false
        end)

      _ ->
        false
    end
  end

  defp has_backdrop_close?(tree, event_name) do
    find_in_tree(tree, fn
      {_tag, attrs, _children} ->
        has_class =
          Enum.any?(attrs, fn
            {"class", class} -> String.contains?(class, "backdrop-blur")
            _ -> false
          end)

        has_close =
          Enum.any?(attrs, fn
            {"phx-click", ^event_name} -> true
            _ -> false
          end)

        has_class and has_close

      _ ->
        false
    end)
  end

  defp find_in_tree(nodes, predicate) when is_list(nodes) do
    Enum.any?(nodes, &find_in_tree(&1, predicate))
  end

  defp find_in_tree({_tag, _attrs, children} = node, predicate) do
    predicate.(node) or find_in_tree(children, predicate)
  end

  defp find_in_tree(_other, _predicate), do: false

  defp has_tag_with_src_containing?(tree, tag_name, substring) when is_list(tree) do
    Enum.any?(tree, &has_tag_with_src_containing?(&1, tag_name, substring))
  end

  defp has_tag_with_src_containing?({tag, attrs, children}, tag_name, substring) do
    src_match =
      tag == tag_name &&
        Enum.any?(attrs, fn
          {"src", src} -> String.contains?(src, substring)
          _ -> false
        end)

    src_match or has_tag_with_src_containing?(children, tag_name, substring)
  end

  defp has_tag_with_src_containing?(_other, _tag_name, _substring), do: false

  defp has_tag_with_attribute?(tree, tag_name, attribute_name) when is_list(tree) do
    Enum.any?(tree, &has_tag_with_attribute?(&1, tag_name, attribute_name))
  end

  defp has_tag_with_attribute?({tag, attrs, children}, tag_name, attribute_name) do
    attr_match =
      tag == tag_name &&
        Enum.any?(attrs, fn
          {^attribute_name, _value} -> true
          {^attribute_name, nil} -> true
          _ -> false
        end)

    attr_match or has_tag_with_attribute?(children, tag_name, attribute_name)
  end

  defp has_tag_with_attribute?(_other, _tag_name, _attribute_name), do: false
end
