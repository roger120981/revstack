defmodule Revstack.SeedsTest do
  use Revstack.DataCase, async: false

  import ExUnit.CaptureIO

  require Ash.Query

  @seeds_file Path.expand("../../priv/repo/seeds.exs", __DIR__)

  setup do
    original_email = Application.get_env(:revstack, :admin_email)
    original_password = Application.get_env(:revstack, :admin_password)

    on_exit(fn ->
      restore_env(:admin_email, original_email)
      restore_env(:admin_password, original_password)
    end)

    :ok
  end

  test "seed script raises when admin email is missing" do
    Application.delete_env(:revstack, :admin_email)
    Application.put_env(:revstack, :admin_password, "seedpassword123!")

    assert_raise RuntimeError, ~r/Missing admin email configuration/, fn ->
      Code.eval_file(@seeds_file)
    end
  end

  test "seed script creates the admin user and is idempotent" do
    email = "seed-admin@example.com"
    password = "seedpassword123!"

    Application.put_env(:revstack, :admin_email, email)
    Application.put_env(:revstack, :admin_password, password)

    first_output = capture_io(fn -> Code.eval_file(@seeds_file) end)
    assert first_output =~ "Admin user created: #{email}"

    admin =
      Revstack.Accounts.User
      |> Ash.Query.filter(email == ^email)
      |> Ash.read_one!(authorize?: false)

    assert admin.admin?

    second_output = capture_io(fn -> Code.eval_file(@seeds_file) end)
    assert second_output =~ "Admin user already exists: #{email}"

    count =
      Revstack.Accounts.User
      |> Ash.Query.filter(email == ^email)
      |> Ash.read!(authorize?: false)
      |> length()

    assert count == 1
  end

  defp restore_env(key, nil), do: Application.delete_env(:revstack, key)
  defp restore_env(key, value), do: Application.put_env(:revstack, key, value)
end
