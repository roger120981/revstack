defmodule Revstack.Tracking.Service do
  @moduledoc """
  Service module for visitor tracking operations.

  Handles finding/creating visitors by IP, recording page visits,
  and enriching visitor location data.
  """

  alias Revstack.Tracking.{Visitor, VisitorPageVisit}

  @doc """
  Tracks a page visit for the given IP address.

  Finds or creates a Visitor by IP, records the page visit,
  and triggers async location enrichment if needed.

  Returns `{:ok, visitor}` or `{:error, reason}`.
  """
  def track_page_visit(attrs) do
    ip = Map.fetch!(attrs, :ip_address)
    user_agent = Map.get(attrs, :user_agent)
    referrer = Map.get(attrs, :referrer)
    path = Map.fetch!(attrs, :path)
    full_url = Map.get(attrs, :full_url)
    query_string = Map.get(attrs, :query_string)
    method = Map.get(attrs, :method)

    with {:ok, visitor} <- find_or_create_visitor(ip, user_agent, referrer),
         {:ok, _page_visit} <-
           create_page_visit(visitor, path, full_url, query_string, method, referrer) do
      maybe_enrich_location(visitor)
      {:ok, visitor}
    end
  end

  @doc """
  Finds an existing visitor by IP or creates a new one.
  If the visitor exists, increments visit_count and updates last_visited_at.
  """
  def find_or_create_visitor(ip_address, user_agent \\ nil, referrer \\ nil) do
    case Visitor.by_ip(ip_address, authorize?: false) do
      {:ok, visitor} ->
        with {:ok, visitor} <- maybe_backfill_referrer(visitor, referrer) do
          Visitor.record_visit(visitor, authorize?: false)
        end

      {:error, _} ->
        Visitor.create(
          %{
            ip_address: ip_address,
            user_agent: user_agent,
            referrer: referrer
          },
          authorize?: false
        )
    end
  end

  @doc """
  Creates a page visit record for a visitor.
  """
  def create_page_visit(
        visitor,
        path,
        full_url \\ nil,
        query_string \\ nil,
        method \\ nil,
        referrer \\ nil
      ) do
    VisitorPageVisit.create(
      %{
        visitor_id: visitor.id,
        path: path,
        full_url: full_url,
        query_string: query_string,
        method: method,
        referrer: referrer
      },
      authorize?: false
    )
  end

  defp maybe_backfill_referrer(visitor, referrer) do
    cond do
      present_referrer?(visitor.referrer) ->
        {:ok, visitor}

      present_referrer?(referrer) ->
        Visitor.backfill_referrer(visitor, %{referrer: referrer}, authorize?: false)

      true ->
        {:ok, visitor}
    end
  end

  defp present_referrer?(value), do: is_binary(value) and String.trim(value) != ""

  @doc """
  Triggers location enrichment for a visitor if location data is missing.
  Runs asynchronously to avoid blocking page rendering.
  """
  def maybe_enrich_location(%Visitor{ip_location_country: nil} = visitor) do
    Task.Supervisor.start_child(
      Revstack.TaskSupervisor,
      fn -> enrich_location(visitor) end
    )
  end

  def maybe_enrich_location(_visitor), do: :ok

  @doc """
  Enriches a visitor record with geolocation data from the configured provider.
  """
  def enrich_location(visitor) do
    case Revstack.Tracking.Geolocation.lookup(visitor.ip_address) do
      {:ok, location} ->
        Visitor.enrich_location(visitor, location, authorize?: false)

      {:error, _reason} ->
        :ok
    end
  end

  @doc """
  Extracts the remote IP from a Plug.Conn as a string.

  Handles proxy headers (X-Forwarded-For) when configured as trusted.
  Falls back to conn.remote_ip.
  """
  def extract_ip(%Plug.Conn{} = conn) do
    forwarded_for =
      conn
      |> Plug.Conn.get_req_header("x-forwarded-for")
      |> List.first()

    ip =
      if forwarded_for && trust_proxy?() do
        forwarded_for
        |> String.split(",")
        |> List.first()
        |> String.trim()
      else
        conn.remote_ip
        |> :inet.ntoa()
        |> to_string()
      end

    normalize_ip(ip)
  end

  defp trust_proxy? do
    Application.get_env(:revstack, :trust_proxy, false)
  end

  defp normalize_ip("::1"), do: "127.0.0.1"
  defp normalize_ip(ip), do: ip
end
