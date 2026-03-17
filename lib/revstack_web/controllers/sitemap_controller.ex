defmodule RevstackWeb.SitemapController do
  use RevstackWeb, :controller

  @paths [
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
  ]

  def index(conn, _params) do
    body =
      [
        ~s(<?xml version="1.0" encoding="UTF-8"?>),
        ~s(<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">),
        Enum.map_join(@paths, "", &url_entry/1),
        "</urlset>"
      ]
      |> IO.iodata_to_binary()

    conn
    |> put_resp_header("content-type", "application/xml; charset=utf-8")
    |> send_resp(:ok, body)
  end

  defp url_entry(path) do
    "<url><loc>#{absolute_url(path)}</loc></url>"
  end

  defp absolute_url(path) do
    RevstackWeb.Endpoint.url()
    |> URI.new!()
    |> URI.merge(path)
    |> to_string()
  end
end
