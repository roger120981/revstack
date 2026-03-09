defmodule RevstackWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in LiveViews.
  """

  import Phoenix.Component
  use RevstackWeb, :verified_routes

  require Logger

  alias Revstack.Tracking.Service

  def on_mount(:current_user, _params, session, socket) do
    {:cont, AshAuthentication.Phoenix.LiveSession.assign_new_resources(socket, session)}
  end

  def on_mount(:live_user_optional, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:track_visitor, _params, session, socket) do
    socket =
      socket
      |> assign(:visitor_ip, session["visitor_ip"])
      |> assign(:visitor_user_agent, session["visitor_user_agent"])
      |> assign(:visitor_referrer, session["visitor_referrer"])
      |> assign(:current_uri, nil)
      |> Phoenix.LiveView.attach_hook(:track_page_visit_params, :handle_params, fn _params,
                                                                                   uri,
                                                                                   socket ->
        if Phoenix.LiveView.connected?(socket) do
          send(
            self(),
            {:track_page_visit, uri,
             socket.assigns.current_uri || socket.assigns.visitor_referrer}
          )
        end

        {:cont, assign(socket, :current_uri, uri)}
      end)
      |> Phoenix.LiveView.attach_hook(:track_page_visit_info, :handle_info, fn
        {:track_page_visit, uri, referrer}, socket ->
          track_page_visit(socket, uri, referrer)
          {:halt, socket}

        _message, socket ->
          {:cont, socket}
      end)

    {:cont, socket}
  end

  def on_mount(:live_user_required, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}
    end
  end

  def on_mount(:live_admin_required, _params, _session, socket) do
    user = socket.assigns[:current_user]

    cond do
      is_nil(user) ->
        {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}

      user.admin? ->
        {:cont, socket}

      true ->
        {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    end
  end

  def on_mount(:live_no_user, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  defp track_page_visit(%{assigns: %{visitor_ip: nil}} = _socket, _uri, _referrer), do: :ok

  defp track_page_visit(socket, uri, referrer) do
    parsed_uri = URI.parse(uri)
    path = parsed_uri.path || "/"

    attrs = %{
      ip_address: socket.assigns.visitor_ip,
      user_agent: socket.assigns.visitor_user_agent,
      referrer: referrer,
      path: path,
      full_url: uri,
      query_string: parsed_uri.query,
      method: "GET"
    }

    safe_track_page_visit(attrs)
  end

  defp safe_track_page_visit(attrs) do
    tracking_service().track_page_visit(attrs)
  rescue
    exception ->
      Logger.warning(
        "Visitor tracking failed without interrupting LiveView: #{Exception.message(exception)}"
      )

      :ok
  catch
    :exit, reason ->
      Logger.warning("Visitor tracking exited without interrupting LiveView: #{inspect(reason)}")

      :ok
  end

  defp tracking_service do
    Application.get_env(:revstack, :tracking_service, Service)
  end
end
