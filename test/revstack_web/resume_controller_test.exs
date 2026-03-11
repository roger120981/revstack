defmodule RevstackWeb.ResumeControllerTest do
  use RevstackWeb.ConnCase, async: true

  alias Revstack.Tracking.{Visitor, VisitorPageVisit}
  require Ash.Query

  describe "GET /resume/kyle-neal-resume.pdf (view)" do
    test "returns 200 with PDF content type", %{conn: conn} do
      conn = get(conn, "/resume/kyle-neal-resume.pdf")

      assert conn.status == 200
      assert {"content-type", "application/pdf"} in conn.resp_headers
    end

    test "sets inline content-disposition for browser viewing", %{conn: conn} do
      conn = get(conn, "/resume/kyle-neal-resume.pdf")

      assert Enum.any?(conn.resp_headers, fn {k, v} ->
               k == "content-disposition" and
                 String.contains?(v, "inline") and
                 String.contains?(v, "kyle-neal-resume.pdf")
             end)
    end

    test "does NOT set attachment content-disposition", %{conn: conn} do
      conn = get(conn, "/resume/kyle-neal-resume.pdf")

      refute Enum.any?(conn.resp_headers, fn {k, v} ->
               k == "content-disposition" and String.contains?(v, "attachment")
             end)
    end

    test "creates a visitor record for the requesting IP", %{conn: conn} do
      conn = %{conn | remote_ip: {198, 51, 100, 42}}
      get(conn, "/resume/kyle-neal-resume.pdf")

      assert {:ok, visitor} = Visitor.by_ip("198.51.100.42", authorize?: false)
      assert visitor.visit_count == 1
    end

    test "records a page visit with the /resume/view tracking path", %{conn: conn} do
      conn = %{conn | remote_ip: {198, 51, 100, 43}}
      get(conn, "/resume/kyle-neal-resume.pdf")

      {:ok, visitor} = Visitor.by_ip("198.51.100.43", authorize?: false)
      visits = VisitorPageVisit.for_visitor!(visitor.id, authorize?: false)
      assert length(visits) == 1

      visit = hd(visits)
      assert visit.path == "/resume/view"
      assert visit.method == "GET"
    end

    test "increments visit count on repeat views from same IP", %{conn: conn} do
      conn = %{conn | remote_ip: {198, 51, 100, 44}}
      get(conn, "/resume/kyle-neal-resume.pdf")
      get(conn, "/resume/kyle-neal-resume.pdf")
      get(conn, "/resume/kyle-neal-resume.pdf")

      {:ok, visitor} = Visitor.by_ip("198.51.100.44", authorize?: false)
      assert visitor.visit_count == 3

      visits = VisitorPageVisit.for_visitor!(visitor.id, authorize?: false)
      assert length(visits) == 3
      assert Enum.all?(visits, &(&1.path == "/resume/view"))
    end

    test "resume_view_count aggregate reflects tracked views", %{conn: conn} do
      conn = %{conn | remote_ip: {198, 51, 100, 45}}
      get(conn, "/resume/kyle-neal-resume.pdf")
      get(conn, "/resume/kyle-neal-resume.pdf")

      {:ok, visitor} = Visitor.by_ip("198.51.100.45", authorize?: false)
      loaded = Ash.load!(visitor, [:resume_view_count], authorize?: false)
      assert loaded.resume_view_count == 2
    end

    test "tracks visitor even without prior session", %{conn: conn} do
      conn = %{conn | remote_ip: {198, 51, 100, 46}}
      get(conn, "/resume/kyle-neal-resume.pdf")

      assert {:ok, _visitor} = Visitor.by_ip("198.51.100.46", authorize?: false)
    end

    test "tracks distinct visitors from different IPs", %{conn: conn} do
      conn1 = %{conn | remote_ip: {198, 51, 100, 47}}
      conn2 = %{conn | remote_ip: {198, 51, 100, 48}}

      get(conn1, "/resume/kyle-neal-resume.pdf")
      get(conn2, "/resume/kyle-neal-resume.pdf")

      {:ok, v1} = Visitor.by_ip("198.51.100.47", authorize?: false)
      {:ok, v2} = Visitor.by_ip("198.51.100.48", authorize?: false)
      assert v1.id != v2.id

      loaded1 = Ash.load!(v1, [:resume_view_count], authorize?: false)
      loaded2 = Ash.load!(v2, [:resume_view_count], authorize?: false)
      assert loaded1.resume_view_count == 1
      assert loaded2.resume_view_count == 1
    end
  end

  describe "GET /resume/download/kyle-neal-resume.pdf (download)" do
    test "returns 200 with PDF content type", %{conn: conn} do
      conn = get(conn, "/resume/download/kyle-neal-resume.pdf")

      assert conn.status == 200
      assert {"content-type", "application/pdf"} in conn.resp_headers
    end

    test "sets attachment content-disposition for file download", %{conn: conn} do
      conn = get(conn, "/resume/download/kyle-neal-resume.pdf")

      assert Enum.any?(conn.resp_headers, fn {k, v} ->
               k == "content-disposition" and
                 String.contains?(v, "attachment") and
                 String.contains?(v, "kyle-neal-resume.pdf")
             end)
    end

    test "does NOT set inline content-disposition", %{conn: conn} do
      conn = get(conn, "/resume/download/kyle-neal-resume.pdf")

      refute Enum.any?(conn.resp_headers, fn {k, v} ->
               k == "content-disposition" and String.contains?(v, "inline")
             end)
    end

    test "creates a visitor record for the requesting IP", %{conn: conn} do
      conn = %{conn | remote_ip: {198, 51, 100, 60}}
      get(conn, "/resume/download/kyle-neal-resume.pdf")

      assert {:ok, visitor} = Visitor.by_ip("198.51.100.60", authorize?: false)
      assert visitor.visit_count == 1
    end

    test "records a page visit with the /resume/download tracking path", %{conn: conn} do
      conn = %{conn | remote_ip: {198, 51, 100, 61}}
      get(conn, "/resume/download/kyle-neal-resume.pdf")

      {:ok, visitor} = Visitor.by_ip("198.51.100.61", authorize?: false)
      visits = VisitorPageVisit.for_visitor!(visitor.id, authorize?: false)
      assert length(visits) == 1
      assert hd(visits).path == "/resume/download"
    end

    test "resume_download_count tracks downloads separately", %{conn: conn} do
      conn = %{conn | remote_ip: {198, 51, 100, 62}}
      get(conn, "/resume/download/kyle-neal-resume.pdf")

      {:ok, visitor} = Visitor.by_ip("198.51.100.62", authorize?: false)
      loaded = Ash.load!(visitor, [:resume_view_count, :resume_download_count], authorize?: false)
      assert loaded.resume_download_count == 1
      assert loaded.resume_view_count == 0
    end

    test "view and download tracked separately", %{conn: conn} do
      conn = %{conn | remote_ip: {198, 51, 100, 63}}
      get(conn, "/resume/kyle-neal-resume.pdf")
      get(conn, "/resume/download/kyle-neal-resume.pdf")

      {:ok, visitor} = Visitor.by_ip("198.51.100.63", authorize?: false)
      loaded = Ash.load!(visitor, [:resume_view_count, :resume_download_count], authorize?: false)
      assert loaded.resume_view_count == 1
      assert loaded.resume_download_count == 1
    end
  end

  describe "content-type correctness (no .txt downloads)" do
    test "view response body is valid PDF binary", %{conn: conn} do
      conn = get(conn, "/resume/kyle-neal-resume.pdf")
      # PDF files start with %PDF magic bytes
      assert conn.status == 200
      assert String.starts_with?(conn.resp_body, "%PDF")
    end

    test "download response body is valid PDF binary", %{conn: conn} do
      conn = get(conn, "/resume/download/kyle-neal-resume.pdf")
      assert conn.status == 200
      assert String.starts_with?(conn.resp_body, "%PDF")
    end

    test "download never returns text/plain content type", %{conn: conn} do
      conn = get(conn, "/resume/download/kyle-neal-resume.pdf")

      refute Enum.any?(conn.resp_headers, fn {k, v} ->
               k == "content-type" and String.contains?(v, "text/plain")
             end)
    end

    test "view never returns text/html content type", %{conn: conn} do
      conn = get(conn, "/resume/kyle-neal-resume.pdf")

      refute Enum.any?(conn.resp_headers, fn {k, v} ->
               k == "content-type" and String.contains?(v, "text/html")
             end)
    end
  end

  describe "resume file location" do
    test "resume path is not in static_paths (avoids Plug.Static interception)" do
      refute "resume" in RevstackWeb.static_paths()
    end

    test "resume file exists in priv/resume/ (not priv/static/)" do
      file = Application.app_dir(:revstack, ["priv", "resume", "kyle-neal-resume.pdf"])
      assert File.exists?(file)
    end

    test "resume_file/0 resolves at runtime, not compile-time" do
      # Ensure the controller module does NOT have a @resume_file module attribute
      # by verifying it uses a runtime function (no __info__(:attributes) for resume_file)
      attrs = RevstackWeb.ResumeController.__info__(:attributes)
      refute Keyword.has_key?(attrs, :resume_file)
    end
  end

  describe "tracking isolation" do
    test "stale priv/static resume file does not intercept controller view", %{conn: conn} do
      stale_dir = Application.app_dir(:revstack, ["priv", "static", "resume"])
      stale_file = Path.join(stale_dir, "kyle-neal-resume.pdf")

      File.mkdir_p!(stale_dir)
      File.write!(stale_file, "this is not a pdf")

      on_exit(fn ->
        File.rm_rf(stale_dir)
      end)

      conn = %{conn | remote_ip: {198, 51, 100, 73}}
      conn = get(conn, "/resume/kyle-neal-resume.pdf")

      assert conn.status == 200
      assert String.starts_with?(conn.resp_body, "%PDF")

      {:ok, visitor} = Visitor.by_ip("198.51.100.73", authorize?: false)
      loaded = Ash.load!(visitor, [:resume_view_count], authorize?: false)
      assert loaded.resume_view_count == 1
    end

    test "view and download create separate page visit records", %{conn: conn} do
      conn = %{conn | remote_ip: {198, 51, 100, 70}}
      get(conn, "/resume/kyle-neal-resume.pdf")
      get(conn, "/resume/download/kyle-neal-resume.pdf")

      {:ok, visitor} = Visitor.by_ip("198.51.100.70", authorize?: false)
      visits = VisitorPageVisit.for_visitor!(visitor.id, authorize?: false)
      assert length(visits) == 2

      paths = Enum.map(visits, & &1.path) |> Enum.sort()
      assert paths == ["/resume/download", "/resume/view"]
    end

    test "multiple downloads from same IP all tracked", %{conn: conn} do
      conn = %{conn | remote_ip: {198, 51, 100, 71}}
      get(conn, "/resume/download/kyle-neal-resume.pdf")
      get(conn, "/resume/download/kyle-neal-resume.pdf")
      get(conn, "/resume/download/kyle-neal-resume.pdf")

      {:ok, visitor} = Visitor.by_ip("198.51.100.71", authorize?: false)
      loaded = Ash.load!(visitor, [:resume_download_count], authorize?: false)
      assert loaded.resume_download_count == 3
    end

    test "resume tracking does not interfere with visit_count", %{conn: conn} do
      conn = %{conn | remote_ip: {198, 51, 100, 72}}
      get(conn, "/resume/kyle-neal-resume.pdf")
      get(conn, "/resume/download/kyle-neal-resume.pdf")

      {:ok, visitor} = Visitor.by_ip("198.51.100.72", authorize?: false)
      assert visitor.visit_count == 2
    end
  end
end
