defmodule RevstackWeb.WhoamiLiveCareerModalTest do
  use RevstackWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  describe "career portfolio modal" do
    test "modal is not rendered on initial page load", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      refute has_element?(view, "#career-portfolio-modal")
    end

    test "clicking a project card opens the modal", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> element("button[phx-click='open_career_modal']", "CSV Repair")
      |> render_click()

      assert has_element?(view, "#career-portfolio-modal")
    end

    test "modal has phx-hook LockBodyScroll for scroll locking", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> element("button[phx-click='open_career_modal']", "CSV Repair")
      |> render_click()

      html = render(view)
      document = LazyHTML.from_fragment(html)
      modal = LazyHTML.query_by_id(document, "career-portfolio-modal")
      tree = LazyHTML.to_tree(modal, sort_attributes: true, skip_whitespace_nodes: true)

      assert has_hook_attribute?(tree, "LockBodyScroll")
    end

    test "closing modal removes it from the DOM", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> element("button[phx-click='open_career_modal']", "CSV Repair")
      |> render_click()

      assert has_element?(view, "#career-portfolio-modal")

      view
      |> element("button[phx-click='close_career_modal']")
      |> render_click()

      refute has_element?(view, "#career-portfolio-modal")
    end

    test "modal shows timeline with all phase projects", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> element("button[phx-click='open_career_modal']", "CSV Repair")
      |> render_click()

      html = render(view)

      assert html =~ "CSV Repair"
      assert html =~ "Infrastructure DNS"
      assert html =~ "Edge Proxy"
      assert html =~ "Infrastructure Monitoring"
      assert html =~ "IP Provisioning"
      assert html =~ "MX DNS"
    end

    test "selecting a project and viewing details works", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> element("button[phx-click='open_career_modal']", "Edge Proxy")
      |> render_click()

      assert has_element?(view, "#career-portfolio-modal")

      view
      |> element("button[phx-click='view_career_detail']")
      |> render_click()

      html = render(view)
      assert html =~ "Overview"
      assert html =~ "Tech Used"
      assert html =~ "How I Designed It"
      assert html =~ "Business Impact"
    end

    test "back button returns from detail to timeline view", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> element("button[phx-click='open_career_modal']", "CSV Repair")
      |> render_click()

      view
      |> element("button[phx-click='view_career_detail']")
      |> render_click()

      # Detail view shows back button
      assert has_element?(view, "button[phx-click='back_career_overview']")

      view
      |> element("button[phx-click='back_career_overview']")
      |> render_click()

      # Back to timeline — no back button, but timeline items are present
      refute has_element?(view, "button[phx-click='back_career_overview']")
      assert has_element?(view, "button[phx-click='view_career_detail']")
    end

    test "backdrop click closes the modal", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      view
      |> element("button[phx-click='open_career_modal']", "CSV Repair")
      |> render_click()

      assert has_element?(view, "#career-portfolio-modal")

      # The backdrop div also has phx-click="close_career_modal"
      html = render(view)
      document = LazyHTML.from_fragment(html)
      modal = LazyHTML.query_by_id(document, "career-portfolio-modal")
      tree = LazyHTML.to_tree(modal, sort_attributes: true, skip_whitespace_nodes: true)

      assert has_backdrop_close?(tree)
    end
  end

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

  defp has_backdrop_close?(tree) do
    find_in_tree(tree, fn
      {_tag, attrs, _children} ->
        has_class =
          Enum.any?(attrs, fn
            {"class", class} -> String.contains?(class, "backdrop-blur")
            _ -> false
          end)

        has_close =
          Enum.any?(attrs, fn
            {"phx-click", "close_career_modal"} -> true
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
end
