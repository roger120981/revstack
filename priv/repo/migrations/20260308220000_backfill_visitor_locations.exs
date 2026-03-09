defmodule Revstack.Repo.Migrations.BackfillVisitorLocations do
  @moduledoc """
  Backfills geolocation data for existing visitors that have a public IP
  but no location data. Uses the MaxMind GeoLite2 web service when
  configured (production).

  Visitors with private IPs or already-enriched location data are skipped.
  """
  use Ecto.Migration

  require Logger

  def up do
    # Flush any pending DDL so we can query the table
    flush()

    # Fetch all visitors without location data
    rows =
      repo().query!(
        "SELECT id, ip_address FROM visitors WHERE ip_location_country IS NULL",
        []
      )

    enriched_count =
      Enum.reduce(rows.rows, 0, fn [id, ip_address], acc ->
        uuid_str = Ecto.UUID.cast!(id)

        case Revstack.Tracking.Geolocation.lookup(ip_address) do
          {:ok, location} ->
            repo().query!(
              """
              UPDATE visitors
              SET ip_location_city = $2,
                  ip_location_region = $3,
                  ip_location_country = $4,
                  ip_location_latitude = $5,
                  ip_location_longitude = $6,
                  updated_at = NOW()
              WHERE id = $1::uuid
              """,
              [
                id,
                location[:ip_location_city],
                location[:ip_location_region],
                location[:ip_location_country],
                location[:ip_location_latitude],
                location[:ip_location_longitude]
              ]
            )

            acc + 1

          {:error, reason} ->
            Logger.info(
              "[BackfillVisitorLocations] Skipping visitor #{uuid_str} (#{ip_address}): #{inspect(reason)}"
            )

            acc
        end
      end)

    Logger.info(
      "[BackfillVisitorLocations] Backfilled location data for #{enriched_count}/#{length(rows.rows)} visitors"
    )
  end

  def down do
    # No-op: we don't clear location data on rollback
    :ok
  end
end
