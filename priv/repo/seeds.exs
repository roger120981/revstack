# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Revstack.Repo.insert!(%Revstack.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

# --- Seed the admin user from environment/config ---
require Ash.Query

admin_email =
  Application.get_env(:revstack, :admin_email) ||
    raise """
    Missing admin email configuration!
    Set the ADMIN_EMAIL environment variable or configure :admin_email in config.
    """

admin_password =
  Application.get_env(:revstack, :admin_password) ||
    raise """
    Missing admin password configuration!
    Set the ADMIN_PASSWORD environment variable or configure :admin_password in config.
    """

case Revstack.Accounts.User
     |> Ash.Query.filter(email == ^admin_email)
     |> Ash.read_one(authorize?: false) do
  {:ok, nil} ->
    Revstack.Accounts.User
    |> Ash.Changeset.for_create(
      :register_with_password,
      %{email: admin_email, password: admin_password, password_confirmation: admin_password},
      authorize?: false
    )
    |> Ash.Changeset.force_change_attribute(:admin?, true)
    |> Ash.create!(authorize?: false)

    IO.puts("Admin user created: #{admin_email}")

  {:ok, _user} ->
    IO.puts("Admin user already exists: #{admin_email}")

  {:error, error} ->
    raise "Failed to check for existing admin: #{inspect(error)}"
end
