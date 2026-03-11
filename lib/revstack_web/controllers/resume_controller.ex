defmodule RevstackWeb.ResumeController do
  use RevstackWeb, :controller

  require Logger

  alias Revstack.Tracking.{ErrorLogger, Service}

  defp resume_file,
    do: Application.app_dir(:revstack, Path.join("priv", "resume/kyle-neal-resume.pdf"))

  def view(conn, _params) do
    serve_resume(conn, :inline, "/resume/view")
  end

  def download(conn, _params) do
    serve_resume(conn, :attachment, "/resume/download")
  end

  defp serve_resume(conn, disposition, tracking_path) do
    file = resume_file()

    if File.exists?(file) do
      safe_track(conn, tracking_path)

      disposition_value =
        case disposition do
          :inline -> ~s(inline; filename="kyle-neal-resume.pdf")
          :attachment -> ~s(attachment; filename="kyle-neal-resume.pdf")
        end

      conn
      |> put_resp_header("content-type", "application/pdf")
      |> put_resp_header("content-disposition", disposition_value)
      |> send_file(200, file)
    else
      conn
      |> put_status(:not_found)
      |> text("Not Found")
      |> halt()
    end
  end

  defp safe_track(conn, tracking_path) do
    ip = get_session(conn, :visitor_ip) || Service.extract_ip(conn)
    user_agent = get_session(conn, :visitor_user_agent)
    referrer = get_session(conn, :visitor_referrer)
    full_url = "#{conn.scheme}://#{conn.host}#{tracking_path}"

    Service.track_page_visit(%{
      ip_address: ip,
      user_agent: user_agent,
      referrer: referrer,
      path: tracking_path,
      full_url: full_url,
      query_string: conn.query_string,
      method: conn.method
    })
  rescue
    exception ->
      ErrorLogger.log_tracking_error(
        %{
          path: tracking_path,
          ip: get_session(conn, :visitor_ip),
          user_agent: get_session(conn, :visitor_user_agent),
          request_path: conn.request_path,
          method: conn.method
        },
        exception
      )

      :ok
  catch
    kind, reason ->
      ErrorLogger.log_tracking_error(
        %{
          path: tracking_path,
          request_path: conn.request_path,
          method: conn.method,
          catch_kind: kind
        },
        reason
      )

      :ok
  end
end
