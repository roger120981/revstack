defmodule Revstack.Tracking.ServiceTest do
  use Revstack.DataCase, async: true

  alias Revstack.Tracking.Service
  alias Revstack.Tracking.VisitorPageVisit

  describe "find_or_create_visitor/3" do
    test "creates a new visitor for a new IP" do
      assert {:ok, visitor} = Service.find_or_create_visitor("203.0.113.1", "TestAgent/1.0")

      assert visitor.ip_address == "203.0.113.1"
      assert visitor.user_agent == "TestAgent/1.0"
      assert visitor.visit_count == 1
      assert visitor.first_visited_at != nil
      assert visitor.last_visited_at != nil
    end

    test "reuses existing visitor for same IP and increments visit_count" do
      {:ok, visitor1} = Service.find_or_create_visitor("203.0.113.2", "TestAgent/1.0")
      assert visitor1.visit_count == 1

      {:ok, visitor2} = Service.find_or_create_visitor("203.0.113.2")
      assert visitor2.id == visitor1.id
      assert visitor2.visit_count == 2
    end

    test "updates last_visited_at on subsequent visits" do
      {:ok, visitor1} = Service.find_or_create_visitor("203.0.113.3")
      first_last_visited = visitor1.last_visited_at

      # Brief pause to ensure timestamp difference
      Process.sleep(10)

      {:ok, visitor2} = Service.find_or_create_visitor("203.0.113.3")
      assert DateTime.compare(visitor2.last_visited_at, first_last_visited) in [:gt, :eq]
    end

    test "preserves first_visited_at on subsequent visits" do
      {:ok, visitor1} = Service.find_or_create_visitor("203.0.113.4")
      first_visited = visitor1.first_visited_at

      {:ok, visitor2} = Service.find_or_create_visitor("203.0.113.4")
      assert visitor2.first_visited_at == first_visited
    end

    test "stores referrer on creation" do
      {:ok, visitor} =
        Service.find_or_create_visitor("203.0.113.5", "TestAgent", "https://google.com")

      assert visitor.referrer == "https://google.com"
    end
  end

  describe "create_page_visit/5" do
    test "creates a page visit record" do
      {:ok, visitor} = Service.find_or_create_visitor("203.0.113.10")

      assert {:ok, visit} = Service.create_page_visit(visitor, "/about")
      assert visit.path == "/about"
      assert visit.visitor_id == visitor.id
      assert visit.visited_at != nil
    end

    test "stores full URL and query string" do
      {:ok, visitor} = Service.find_or_create_visitor("203.0.113.11")

      assert {:ok, visit} =
               Service.create_page_visit(
                 visitor,
                 "/services",
                 "http://localhost/services?ref=google",
                 "ref=google",
                 "GET"
               )

      assert visit.full_url == "http://localhost/services?ref=google"
      assert visit.query_string == "ref=google"
      assert visit.method == "GET"
    end

    test "creates multiple page visits for same visitor" do
      {:ok, visitor} = Service.find_or_create_visitor("203.0.113.12")

      {:ok, _} = Service.create_page_visit(visitor, "/")
      {:ok, _} = Service.create_page_visit(visitor, "/about")
      {:ok, _} = Service.create_page_visit(visitor, "/contact")

      visits = VisitorPageVisit.for_visitor!(visitor.id, authorize?: false)
      assert length(visits) == 3
    end
  end

  describe "track_page_visit/1" do
    test "creates visitor and page visit in one call" do
      assert {:ok, visitor} =
               Service.track_page_visit(%{
                 ip_address: "203.0.113.20",
                 user_agent: "TestUA",
                 referrer: nil,
                 path: "/",
                 full_url: "http://localhost/",
                 query_string: nil,
                 method: "GET"
               })

      assert visitor.ip_address == "203.0.113.20"
      assert visitor.visit_count == 1

      visits = VisitorPageVisit.for_visitor!(visitor.id, authorize?: false)
      assert length(visits) == 1
      assert hd(visits).path == "/"
    end

    test "tracks multiple pages for the same visitor" do
      attrs = %{
        ip_address: "203.0.113.21",
        user_agent: "TestUA",
        referrer: nil,
        path: "/",
        full_url: nil,
        query_string: nil,
        method: "GET"
      }

      {:ok, _} = Service.track_page_visit(attrs)
      {:ok, _} = Service.track_page_visit(%{attrs | path: "/about"})
      {:ok, visitor} = Service.track_page_visit(%{attrs | path: "/contact"})

      assert visitor.visit_count == 3

      visits = VisitorPageVisit.for_visitor!(visitor.id, authorize?: false)
      assert length(visits) == 3
    end
  end

  describe "extract_ip/1" do
    test "extracts IP from conn.remote_ip" do
      conn = %Plug.Conn{remote_ip: {192, 168, 1, 100}}
      assert Service.extract_ip(conn) == "192.168.1.100"
    end

    test "normalizes ::1 to 127.0.0.1" do
      conn = %Plug.Conn{remote_ip: {0, 0, 0, 0, 0, 0, 0, 1}}
      assert Service.extract_ip(conn) == "127.0.0.1"
    end
  end
end
