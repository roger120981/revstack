defmodule Revstack.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      RevstackWeb.Telemetry,
      Revstack.Repo,
      {DNSCluster, query: Application.get_env(:revstack, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Revstack.PubSub},
      {Task.Supervisor, name: Revstack.TaskSupervisor},
      # Start a worker by calling: Revstack.Worker.start_link(arg)
      # {Revstack.Worker, arg},
      # Start to serve requests, typically the last entry
      RevstackWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :revstack]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Revstack.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    RevstackWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
