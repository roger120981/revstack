defmodule RevstackWeb.SitemapControllerTest do
  use RevstackWeb.ConnCase, async: true

  describe "GET /sitemap.xml" do
    test "returns an XML sitemap for public routes", %{conn: conn} do
      conn = get(conn, "/sitemap.xml")
      base_url = RevstackWeb.Endpoint.url()

      assert conn.status == 200
      assert ["application/xml; charset=utf-8"] == get_resp_header(conn, "content-type")
      assert conn.resp_body =~ ~s(<?xml version="1.0" encoding="UTF-8"?>)
      assert conn.resp_body =~ ~s(<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">)

      for path <- [
            "/",
            "/about",
            "/services",
            "/estimate",
            "/contact",
            "/privacy",
            "/thanks",
            "/whoami",
            "/resume/kyle-neal-resume.pdf",
            "/resume/download/kyle-neal-resume.pdf"
          ] do
        assert conn.resp_body =~ "<loc>#{base_url}#{path}</loc>"
      end
    end

    test "does not render a 404 response", %{conn: conn} do
      conn = get(conn, "/sitemap.xml")

      refute conn.resp_body == "Not Found"
    end
  end
end
