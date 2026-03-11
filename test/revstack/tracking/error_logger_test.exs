defmodule Revstack.Tracking.ErrorLoggerTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureLog

  alias Revstack.Tracking.ErrorLogger

  @test_log_dir "tmp/test_tracking_logs"

  setup do
    File.rm_rf!(@test_log_dir)
    Application.put_env(:revstack, :tracking_error_log_dir, @test_log_dir)

    on_exit(fn ->
      Application.delete_env(:revstack, :tracking_error_log_dir)
      File.rm_rf!(@test_log_dir)
    end)

    :ok
  end

  describe "log_tracking_error/2" do
    test "logs error to standard Logger" do
      context = %{path: "/test", ip: "1.2.3.4"}
      error = %RuntimeError{message: "boom"}

      log =
        capture_log(fn ->
          ErrorLogger.log_tracking_error(context, error)
        end)

      assert log =~ "TRACKING_ERROR"
      assert log =~ "boom"
    end

    test "writes error to dedicated log file" do
      context = %{path: "/resume/view", ip: "10.0.0.1", user_agent: "TestBot"}
      error = %RuntimeError{message: "tracking failed"}

      capture_log(fn ->
        ErrorLogger.log_tracking_error(context, error)
      end)

      log_path = ErrorLogger.log_file_path()
      assert File.exists?(log_path)

      content = File.read!(log_path)
      assert content =~ "TRACKING_ERROR"
      assert content =~ "tracking failed"
      assert content =~ "/resume/view"
      assert content =~ "10.0.0.1"
      assert content =~ "TestBot"
    end

    test "appends multiple errors to the same file" do
      capture_log(fn ->
        ErrorLogger.log_tracking_error(%{path: "/first"}, %RuntimeError{message: "error1"})
        ErrorLogger.log_tracking_error(%{path: "/second"}, %RuntimeError{message: "error2"})
      end)

      content = File.read!(ErrorLogger.log_file_path())
      assert content =~ "error1"
      assert content =~ "error2"
      assert content =~ "/first"
      assert content =~ "/second"
    end

    test "never raises even with invalid context" do
      assert :ok =
               capture_log(fn ->
                 ErrorLogger.log_tracking_error(nil, nil)
               end)
               |> then(fn _log -> :ok end)
    end

    test "returns :ok" do
      result =
        capture_log(fn ->
          send(self(), {:result, ErrorLogger.log_tracking_error(%{}, "test error")})
        end)

      assert result =~ "TRACKING_ERROR"
      assert_received {:result, :ok}
    end
  end

  describe "log_file_path/0" do
    test "uses configured directory" do
      path = ErrorLogger.log_file_path()
      assert String.starts_with?(path, @test_log_dir)
      assert String.ends_with?(path, "tracking_errors.log")
    end
  end

  describe "simulated tracking failure" do
    test "tracking error gets logged to file when service raises" do
      context = %{
        path: "/resume/view",
        ip: "192.168.1.1",
        user_agent: "Mozilla/5.0",
        request_path: "/resume/kyle-neal-resume.pdf",
        method: "GET"
      }

      error = %RuntimeError{message: "simulated database connection failure"}

      capture_log(fn ->
        ErrorLogger.log_tracking_error(context, error)
      end)

      log_path = ErrorLogger.log_file_path()
      assert File.exists?(log_path)

      content = File.read!(log_path)
      assert content =~ "simulated database connection failure"
      assert content =~ "/resume/view"
      assert content =~ "192.168.1.1"
      assert content =~ "Mozilla/5.0"
      assert content =~ "---"
    end
  end
end
