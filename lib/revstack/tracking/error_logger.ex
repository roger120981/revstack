defmodule Revstack.Tracking.ErrorLogger do
  @moduledoc """
  Dedicated error logger for visitor tracking failures.

  Logs tracking errors to a separate file (`log/tracking_errors.log`) in addition
  to the standard Logger output. This ensures tracking failures are auditable
  without cluttering the main application log.
  """

  require Logger

  @log_dir "log"
  @log_file "tracking_errors.log"

  @doc """
  Logs a tracking error to both the standard Logger and the dedicated tracking
  error log file. The file entry includes the full request context and error
  details for debugging.

  Returns `:ok` — this function never raises.
  """
  def log_tracking_error(context, error) do
    message = format_error_message(context, error)

    Logger.error(message)
    append_to_file(message)

    :ok
  rescue
    _ -> :ok
  end

  @doc """
  Returns the absolute path to the tracking error log file.
  """
  def log_file_path do
    Path.join(log_dir(), @log_file)
  end

  defp log_dir do
    Application.get_env(:revstack, :tracking_error_log_dir, @log_dir)
  end

  defp format_error_message(context, error) do
    timestamp = DateTime.utc_now() |> DateTime.to_iso8601()

    """
    [TRACKING_ERROR] #{timestamp}
    Error: #{inspect(error)}
    Context: #{inspect(context, pretty: true)}
    ---
    """
  end

  defp append_to_file(message) do
    path = log_file_path()
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, message, [:append])
  rescue
    _ -> :ok
  end
end
