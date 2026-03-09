# Skip MaxMind integration tests unless credentials are available
exclude =
  if System.get_env("MAXMIND_ACCOUNT_ID") && System.get_env("MAXMIND_LICENSE_KEY") do
    []
  else
    [:maxmind_integration]
  end

ExUnit.start(exclude: exclude)
Ecto.Adapters.SQL.Sandbox.mode(Revstack.Repo, :manual)
