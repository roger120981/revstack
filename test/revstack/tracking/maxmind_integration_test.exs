defmodule Revstack.Tracking.MaxmindIntegrationTest do
  @moduledoc """
  Integration tests for MaxMind GeoLite2 web service.

  These tests are skipped unless MAXMIND_ACCOUNT_ID and MAXMIND_LICENSE_KEY
  environment variables are set. This ensures CI (GitHub Actions) still passes
  without credentials.

  To run locally:

      MAXMIND_ACCOUNT_ID=your_id MAXMIND_LICENSE_KEY=your_key mix test test/revstack/tracking/maxmind_integration_test.exs
  """
  use ExUnit.Case, async: false

  alias Revstack.Tracking.Geolocation

  @maxmind_account_id System.get_env("MAXMIND_ACCOUNT_ID")
  @maxmind_license_key System.get_env("MAXMIND_LICENSE_KEY")

  @moduletag :maxmind_integration

  setup do
    if is_nil(@maxmind_account_id) || is_nil(@maxmind_license_key) do
      :skip
    else
      original_provider = Application.get_env(:revstack, :geolocation_provider)
      original_account = Application.get_env(:revstack, :maxmind_account_id)
      original_key = Application.get_env(:revstack, :maxmind_license_key)

      Application.put_env(:revstack, :geolocation_provider, :maxmind)
      Application.put_env(:revstack, :maxmind_account_id, @maxmind_account_id)
      Application.put_env(:revstack, :maxmind_license_key, @maxmind_license_key)

      on_exit(fn ->
        if original_provider do
          Application.put_env(:revstack, :geolocation_provider, original_provider)
        else
          Application.delete_env(:revstack, :geolocation_provider)
        end

        if original_account do
          Application.put_env(:revstack, :maxmind_account_id, original_account)
        else
          Application.delete_env(:revstack, :maxmind_account_id)
        end

        if original_key do
          Application.put_env(:revstack, :maxmind_license_key, original_key)
        else
          Application.delete_env(:revstack, :maxmind_license_key)
        end
      end)

      :ok
    end
  end

  describe "MaxMind GeoLite2 integration" do
    test "returns city-level geolocation for a known public IP" do
      # 72.229.28.185 is a NYC-area IP that MaxMind resolves with city data
      assert {:ok, result} = Geolocation.lookup("72.229.28.185")

      assert result.ip_location_country == "United States"
      assert result.ip_location_region == "New York"
      assert result.ip_location_city == "New York"
      assert is_float(result.ip_location_latitude)
      assert is_float(result.ip_location_longitude)
    end

    test "returns country-level geolocation for Google DNS (8.8.8.8)" do
      assert {:ok, result} = Geolocation.lookup("8.8.8.8")

      assert result.ip_location_country == "United States"
      # Google DNS may not have city/region data
      assert is_float(result.ip_location_latitude)
      assert is_float(result.ip_location_longitude)
    end

    test "still rejects private IPs even when MaxMind is configured" do
      assert {:error, :private_ip} = Geolocation.lookup("127.0.0.1")
      assert {:error, :private_ip} = Geolocation.lookup("10.0.0.1")
      assert {:error, :private_ip} = Geolocation.lookup("192.168.1.1")
    end
  end
end
