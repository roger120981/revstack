defmodule Revstack.Tracking.Geolocation do
  @moduledoc """
  Geolocation provider for IP address lookups.

  Uses the MaxMind GeoLite2 web service for production IP geolocation.
  Requires `MAXMIND_ACCOUNT_ID` and `MAXMIND_LICENSE_KEY` environment
  variables to be set for the `:maxmind` provider.

  Configuration:

      # config/runtime.exs (production)
      config :revstack, geolocation_provider: :maxmind

      # config/dev.exs and config/test.exs
      config :revstack, geolocation_provider: :disabled

  Geolocation is disabled by default. It should only be enabled in
  production where real public IPs are available.
  """

  require Logger

  @doc """
  Looks up geolocation data for an IP address.

  Returns {:ok, map} with location fields or {:error, reason}.
  """
  def lookup(ip_address) do
    if private_ip?(ip_address) do
      {:error, :private_ip}
    else
      provider = Application.get_env(:revstack, :geolocation_provider, :disabled)
      do_lookup(provider, ip_address)
    end
  end

  defp do_lookup(:maxmind, ip_address) do
    account_id = Application.get_env(:revstack, :maxmind_account_id)
    license_key = Application.get_env(:revstack, :maxmind_license_key)

    if is_nil(account_id) || is_nil(license_key) do
      Logger.warning("MaxMind credentials not configured, skipping geolocation")
      {:error, :not_configured}
    else
      case ensure_req_started() do
        :ok ->
          url = "#{maxmind_base_url()}/#{URI.encode(ip_address)}"

          case Req.get(url,
                 auth: {:basic, "#{account_id}:#{license_key}"},
                 receive_timeout: 5_000,
                 connect_options: [timeout: 5_000]
               ) do
            {:ok, %Req.Response{status: 200, body: body}} ->
              {:ok, parse_maxmind_response(body)}

            {:ok, %Req.Response{status: status, body: body}} ->
              Logger.error(
                "MaxMind lookup failed for #{ip_address}: status=#{status} body=#{inspect(body)}"
              )

              {:error, :lookup_failed}

            {:error, reason} ->
              Logger.error("MaxMind request failed for #{ip_address}: #{inspect(reason)}")
              {:error, :request_failed}
          end

        {:error, reason} ->
          Logger.error("Req could not be started, skipping geolocation: #{inspect(reason)}")
          {:error, :request_failed}
      end
    end
  end

  defp do_lookup(:disabled, _ip_address) do
    {:error, :not_configured}
  end

  defp do_lookup(provider, _ip_address) do
    Logger.warning("Unknown geolocation provider: #{inspect(provider)}")
    {:error, :unknown_provider}
  end

  defp parse_maxmind_response(body) do
    city = get_in(body, ["city", "names", "en"])
    region = get_in(body, ["subdivisions", Access.at(0), "names", "en"])
    country = get_in(body, ["country", "names", "en"])
    latitude = get_in(body, ["location", "latitude"])
    longitude = get_in(body, ["location", "longitude"])

    %{
      ip_location_city: city,
      ip_location_region: region,
      ip_location_country: country,
      ip_location_latitude: latitude && latitude / 1,
      ip_location_longitude: longitude && longitude / 1
    }
  end

  defp private_ip?("127." <> _), do: true
  defp private_ip?("10." <> _), do: true
  defp private_ip?("192.168." <> _), do: true
  defp private_ip?("0.0.0.0"), do: true
  defp private_ip?("::1"), do: true
  defp private_ip?("localhost"), do: true

  defp private_ip?("172." <> rest) do
    case Integer.parse(rest) do
      {second_octet, _} when second_octet >= 16 and second_octet <= 31 -> true
      _ -> false
    end
  end

  defp private_ip?(_), do: false

  defp ensure_req_started do
    case Application.ensure_all_started(:req) do
      {:ok, _started_apps} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  defp maxmind_base_url do
    Application.get_env(:revstack, :maxmind_base_url, "https://geolite.info/geoip/v2.1/city")
  end
end
