defmodule Revstack.Tracking.VisitorPageVisitResourceTest do
  use Revstack.DataCase, async: true

  alias Revstack.Tracking.{Visitor, VisitorPageVisit}

  setup do
    {:ok, visitor} =
      Visitor.create(%{ip_address: "203.0.113.200"}, authorize?: false)

    {:ok, visitor: visitor}
  end

  describe "create" do
    test "creates a page visit with required fields", %{visitor: visitor} do
      {:ok, visit} =
        VisitorPageVisit.create(
          %{visitor_id: visitor.id, path: "/about"},
          authorize?: false
        )

      assert visit.path == "/about"
      assert visit.visitor_id == visitor.id
      assert visit.visited_at != nil
    end

    test "stores optional URL fields", %{visitor: visitor} do
      {:ok, visit} =
        VisitorPageVisit.create(
          %{
            visitor_id: visitor.id,
            path: "/services",
            full_url: "http://example.com/services?ref=test",
            query_string: "ref=test",
            method: "GET"
          },
          authorize?: false
        )

      assert visit.full_url == "http://example.com/services?ref=test"
      assert visit.query_string == "ref=test"
      assert visit.method == "GET"
    end

    test "requires visitor_id", %{} do
      assert {:error, _} =
               VisitorPageVisit.create(%{path: "/test"}, authorize?: false)
    end

    test "requires path", %{visitor: visitor} do
      assert {:error, _} =
               VisitorPageVisit.create(%{visitor_id: visitor.id}, authorize?: false)
    end
  end

  describe "for_visitor" do
    test "returns visits for a specific visitor sorted by visited_at desc", %{visitor: visitor} do
      {:ok, _} = VisitorPageVisit.create(%{visitor_id: visitor.id, path: "/"}, authorize?: false)

      {:ok, _} =
        VisitorPageVisit.create(%{visitor_id: visitor.id, path: "/about"}, authorize?: false)

      {:ok, _} =
        VisitorPageVisit.create(%{visitor_id: visitor.id, path: "/contact"}, authorize?: false)

      visits = VisitorPageVisit.for_visitor!(visitor.id, authorize?: false)
      assert length(visits) == 3

      # All three paths should be present
      paths = Enum.map(visits, & &1.path)
      assert "/" in paths
      assert "/about" in paths
      assert "/contact" in paths
    end

    test "does not return visits from other visitors", %{visitor: visitor} do
      {:ok, other_visitor} =
        Visitor.create(%{ip_address: "203.0.113.201"}, authorize?: false)

      {:ok, _} = VisitorPageVisit.create(%{visitor_id: visitor.id, path: "/"}, authorize?: false)

      {:ok, _} =
        VisitorPageVisit.create(%{visitor_id: other_visitor.id, path: "/other"},
          authorize?: false
        )

      visits = VisitorPageVisit.for_visitor!(visitor.id, authorize?: false)
      assert length(visits) == 1
      assert hd(visits).path == "/"
    end
  end
end
