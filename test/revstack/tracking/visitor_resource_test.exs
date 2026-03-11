defmodule Revstack.Tracking.VisitorResourceTest do
  use Revstack.DataCase, async: true

  alias Revstack.Tracking.Visitor

  describe "create" do
    test "creates a visitor with required fields" do
      {:ok, visitor} =
        Visitor.create(
          %{ip_address: "203.0.113.100", user_agent: "TestBot/1.0"},
          authorize?: false
        )

      assert visitor.ip_address == "203.0.113.100"
      assert visitor.user_agent == "TestBot/1.0"
      assert visitor.visit_count == 1
      assert visitor.first_visited_at != nil
      assert visitor.last_visited_at != nil
    end

    test "requires ip_address" do
      assert {:error, _} = Visitor.create(%{}, authorize?: false)
    end

    test "enforces unique IP identity" do
      {:ok, _} =
        Visitor.create(%{ip_address: "203.0.113.101"}, authorize?: false)

      assert {:error, _} =
               Visitor.create(%{ip_address: "203.0.113.101"}, authorize?: false)
    end

    test "sets optional location fields" do
      {:ok, visitor} =
        Visitor.create(
          %{
            ip_address: "203.0.113.102",
            ip_location_city: "New York",
            ip_location_region: "NY",
            ip_location_country: "United States",
            ip_location_latitude: 40.7128,
            ip_location_longitude: -74.006
          },
          authorize?: false
        )

      assert visitor.ip_location_city == "New York"
      assert visitor.ip_location_region == "NY"
      assert visitor.ip_location_country == "United States"
      assert_in_delta visitor.ip_location_latitude, 40.7128, 0.001
      assert_in_delta visitor.ip_location_longitude, -74.006, 0.001
    end
  end

  describe "by_ip" do
    test "finds visitor by IP address" do
      {:ok, created} =
        Visitor.create(%{ip_address: "203.0.113.110"}, authorize?: false)

      {:ok, found} = Visitor.by_ip("203.0.113.110", authorize?: false)
      assert found.id == created.id
    end

    test "returns not found for unknown IP" do
      assert {:error, _} =
               Visitor.by_ip("203.0.113.999", authorize?: false)
    end
  end

  describe "record_visit" do
    test "increments visit_count" do
      {:ok, visitor} =
        Visitor.create(%{ip_address: "203.0.113.120"}, authorize?: false)

      assert visitor.visit_count == 1

      {:ok, updated} = Visitor.record_visit(visitor, authorize?: false)
      assert updated.visit_count == 2

      {:ok, updated2} = Visitor.record_visit(updated, authorize?: false)
      assert updated2.visit_count == 3
    end

    test "updates last_visited_at" do
      {:ok, visitor} =
        Visitor.create(%{ip_address: "203.0.113.121"}, authorize?: false)

      original_last = visitor.last_visited_at
      Process.sleep(10)

      {:ok, updated} = Visitor.record_visit(visitor, authorize?: false)
      assert DateTime.compare(updated.last_visited_at, original_last) in [:gt, :eq]
    end
  end

  describe "enrich_location" do
    test "updates location fields" do
      {:ok, visitor} =
        Visitor.create(%{ip_address: "203.0.113.130"}, authorize?: false)

      assert visitor.ip_location_city == nil

      {:ok, enriched} =
        Visitor.enrich_location(
          visitor,
          %{
            ip_location_city: "Portland",
            ip_location_region: "OR",
            ip_location_country: "United States"
          },
          authorize?: false
        )

      assert enriched.ip_location_city == "Portland"
      assert enriched.ip_location_region == "OR"
      assert enriched.ip_location_country == "United States"
    end
  end

  describe "aggregates" do
    test "lead_count reflects matching leads by IP" do
      {:ok, visitor} =
        Visitor.create(%{ip_address: "203.0.113.140"}, authorize?: false)

      # Create leads with matching IP
      Revstack.Consulting.Lead
      |> Ash.Changeset.for_create(
        :create,
        %{
          name: "Test Lead",
          email: "test@example.com",
          message: "This is a detailed test message that is at least twenty characters.",
          preferred_contact_method: :email,
          honeypot: "",
          request_ip: "203.0.113.140"
        },
        authorize?: false
      )
      |> Ash.create!(authorize?: false)

      loaded = Ash.load!(visitor, [:lead_count], authorize?: false)
      assert loaded.lead_count == 1
    end

    test "estimate_count reflects matching estimates by IP" do
      {:ok, visitor} =
        Visitor.create(%{ip_address: "203.0.113.150"}, authorize?: false)

      Revstack.Consulting.EstimateRequest
      |> Ash.Changeset.for_create(
        :create,
        %{
          name: "Test Estimate",
          email: "est@example.com",
          project_type: :phoenix_liveview_app,
          summary: "This is a detailed test estimate summary that is at least thirty characters.",
          request_ip: "203.0.113.150"
        },
        authorize?: false
      )
      |> Ash.create!(authorize?: false)

      loaded = Ash.load!(visitor, [:estimate_count], authorize?: false)
      assert loaded.estimate_count == 1
    end

    test "resume_view_count counts page visits to the resume view path" do
      {:ok, visitor} =
        Visitor.create(%{ip_address: "203.0.113.160"}, authorize?: false)

      # Create a resume view page visit
      Revstack.Tracking.VisitorPageVisit.create(
        %{
          visitor_id: visitor.id,
          path: "/resume/view"
        },
        authorize?: false
      )

      # Create a regular page visit (should not count)
      Revstack.Tracking.VisitorPageVisit.create(
        %{
          visitor_id: visitor.id,
          path: "/about"
        },
        authorize?: false
      )

      # Create a resume download (should not count as view)
      Revstack.Tracking.VisitorPageVisit.create(
        %{
          visitor_id: visitor.id,
          path: "/resume/download"
        },
        authorize?: false
      )

      loaded = Ash.load!(visitor, [:resume_view_count], authorize?: false)
      assert loaded.resume_view_count == 1
    end

    test "resume_view_count is zero when no resume views exist" do
      {:ok, visitor} =
        Visitor.create(%{ip_address: "203.0.113.161"}, authorize?: false)

      Revstack.Tracking.VisitorPageVisit.create(
        %{
          visitor_id: visitor.id,
          path: "/contact"
        },
        authorize?: false
      )

      loaded = Ash.load!(visitor, [:resume_view_count], authorize?: false)
      assert loaded.resume_view_count == 0
    end

    test "resume_view_count increments with multiple resume views" do
      {:ok, visitor} =
        Visitor.create(%{ip_address: "203.0.113.162"}, authorize?: false)

      for _ <- 1..3 do
        Revstack.Tracking.VisitorPageVisit.create(
          %{visitor_id: visitor.id, path: "/resume/view"},
          authorize?: false
        )
      end

      loaded = Ash.load!(visitor, [:resume_view_count], authorize?: false)
      assert loaded.resume_view_count == 3
    end

    test "resume_download_count counts page visits to the resume download path" do
      {:ok, visitor} =
        Visitor.create(%{ip_address: "203.0.113.163"}, authorize?: false)

      Revstack.Tracking.VisitorPageVisit.create(
        %{visitor_id: visitor.id, path: "/resume/download"},
        authorize?: false
      )

      Revstack.Tracking.VisitorPageVisit.create(
        %{visitor_id: visitor.id, path: "/resume/download"},
        authorize?: false
      )

      # Regular page visit should not count
      Revstack.Tracking.VisitorPageVisit.create(
        %{visitor_id: visitor.id, path: "/about"},
        authorize?: false
      )

      loaded = Ash.load!(visitor, [:resume_download_count], authorize?: false)
      assert loaded.resume_download_count == 2
    end

    test "resume_download_count is zero when no downloads exist" do
      {:ok, visitor} =
        Visitor.create(%{ip_address: "203.0.113.164"}, authorize?: false)

      Revstack.Tracking.VisitorPageVisit.create(
        %{visitor_id: visitor.id, path: "/resume/view"},
        authorize?: false
      )

      loaded = Ash.load!(visitor, [:resume_download_count], authorize?: false)
      assert loaded.resume_download_count == 0
    end
  end
end
