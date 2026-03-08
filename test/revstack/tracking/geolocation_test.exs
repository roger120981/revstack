defmodule Revstack.Tracking.GeolocationTest do
  use ExUnit.Case, async: true

  alias Revstack.Tracking.Geolocation

  describe "lookup/1" do
    test "returns error for localhost IPs" do
      assert {:error, :private_ip} = Geolocation.lookup("127.0.0.1")
    end

    test "returns error for private 10.x IPs" do
      assert {:error, :private_ip} = Geolocation.lookup("10.0.0.1")
    end

    test "returns error for private 192.168.x IPs" do
      assert {:error, :private_ip} = Geolocation.lookup("192.168.1.1")
    end

    test "returns error for 0.0.0.0" do
      assert {:error, :private_ip} = Geolocation.lookup("0.0.0.0")
    end

    test "returns error for ::1" do
      assert {:error, :private_ip} = Geolocation.lookup("::1")
    end

    test "returns error for private 172.16-31.x IPs" do
      assert {:error, :private_ip} = Geolocation.lookup("172.16.0.1")
      assert {:error, :private_ip} = Geolocation.lookup("172.31.255.255")
    end

    test "does not treat 172.32.x as private" do
      # This IP is not in the private range, but since geolocation is disabled in test
      # it should return :not_configured
      assert {:error, :not_configured} = Geolocation.lookup("172.32.0.1")
    end

    test "defaults to :disabled provider when not configured" do
      # Default provider is :disabled, so public IPs return :not_configured
      assert {:error, :not_configured} = Geolocation.lookup("8.8.8.8")
    end

    test "returns error for maxmind without credentials" do
      original = Application.get_env(:revstack, :geolocation_provider)

      try do
        Application.put_env(:revstack, :geolocation_provider, :maxmind)
        assert {:error, :not_configured} = Geolocation.lookup("8.8.8.8")
      after
        if original do
          Application.put_env(:revstack, :geolocation_provider, original)
        else
          Application.delete_env(:revstack, :geolocation_provider)
        end
      end
    end
  end
end
