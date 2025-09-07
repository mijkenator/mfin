defmodule Mfin.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MfinWeb.Telemetry,
      Mfin.Repo,
      {DNSCluster, query: Application.get_env(:mfin, :dns_cluster_query) || :ignore},
      {Oban, Application.fetch_env!(:mfin, Oban)},
      {Phoenix.PubSub, name: Mfin.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Mfin.Finch},
      # Start a worker by calling: Mfin.Worker.start_link(arg)
      # {Mfin.Worker, arg},
      # Start to serve requests, typically the last entry
      MfinWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Mfin.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    MfinWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
