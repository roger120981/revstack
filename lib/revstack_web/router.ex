defmodule RevstackWeb.Router do
  use RevstackWeb, :router

  use AshAuthentication.Phoenix.Router

  import AshAuthentication.Plug.Helpers

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {RevstackWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
    plug RevstackWeb.Plugs.VisitorTracking
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
    plug :set_actor, :user
  end

  # Public LiveView routes
  scope "/", RevstackWeb do
    pipe_through :browser

    ash_authentication_live_session :public_routes,
      on_mount: [
        {RevstackWeb.LiveUserAuth, :live_user_optional},
        {RevstackWeb.LiveUserAuth, :track_visitor}
      ] do
      live "/", WhoamiLive
      live "/about", AboutLive
      live "/services", ServicesLive
      live "/estimate", EstimateLive
      live "/contact", ContactLive
      live "/privacy", PrivacyLive
      live "/thanks", ThanksLive
      live "/whoami", WhoamiLive
    end
  end

  # Admin panel (authenticated)
  scope "/admin", RevstackWeb.Admin do
    pipe_through :browser

    ash_authentication_live_session :admin_routes,
      on_mount: [{RevstackWeb.LiveUserAuth, :live_admin_required}] do
      live "/", DashboardLive, :index
      live "/leads", LeadLive.Index, :index
      live "/leads/:id", LeadLive.Show, :show
      live "/leads/:id/edit", LeadLive.Show, :edit
      live "/estimates", EstimateRequestLive.Index, :index
      live "/estimates/:id", EstimateRequestLive.Show, :show
      live "/estimates/:id/edit", EstimateRequestLive.Show, :edit
      live "/visitors", VisitorLive.Index, :index
      live "/visitors/:id", VisitorLive.Show, :show
    end
  end

  scope "/", RevstackWeb do
    pipe_through :browser

    auth_routes AuthController, Revstack.Accounts.User, path: "/auth"
    sign_out_route AuthController

    sign_in_route register_path: nil,
                  reset_path: "/reset",
                  auth_routes_prefix: "/auth",
                  on_mount: [{RevstackWeb.LiveUserAuth, :live_no_user}],
                  overrides: [
                    RevstackWeb.AuthOverrides,
                    Elixir.AshAuthentication.Phoenix.Overrides.DaisyUI
                  ]

    reset_route auth_routes_prefix: "/auth",
                overrides: [
                  RevstackWeb.AuthOverrides,
                  Elixir.AshAuthentication.Phoenix.Overrides.DaisyUI
                ]
  end

  # Other scopes may use custom stacks.
  # scope "/api", RevstackWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:revstack, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: RevstackWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  if Application.compile_env(:revstack, :dev_routes) do
    import AshAdmin.Router

    scope "/dev" do
      pipe_through :browser

      ash_admin("/ash-admin")
    end
  end
end
