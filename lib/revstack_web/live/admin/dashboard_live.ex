defmodule RevstackWeb.Admin.DashboardLive do
  use RevstackWeb, :live_view

  require Ash.Query

  @impl true
  def mount(_params, _session, socket) do
    visitor_count =
      Revstack.Tracking.Visitor
      |> Ash.count!(authorize?: false)

    lead_count =
      Revstack.Consulting.Lead
      |> Ash.count!(authorize?: false)

    new_lead_count =
      Revstack.Consulting.Lead
      |> Ash.Query.filter(status == :new)
      |> Ash.count!(authorize?: false)

    resume_view_count =
      Revstack.Tracking.VisitorPageVisit
      |> Ash.Query.filter(path == "/resume/view")
      |> Ash.count!(authorize?: false)

    resume_download_count =
      Revstack.Tracking.VisitorPageVisit
      |> Ash.Query.filter(path == "/resume/download")
      |> Ash.count!(authorize?: false)

    estimate_count =
      Revstack.Consulting.EstimateRequest
      |> Ash.count!(authorize?: false)

    new_estimate_count =
      Revstack.Consulting.EstimateRequest
      |> Ash.Query.filter(status == :new)
      |> Ash.count!(authorize?: false)

    {:ok,
     assign(socket,
       page_title: "Admin Dashboard",
       current_path: "/admin",
       visitor_count: visitor_count,
       lead_count: lead_count,
       new_lead_count: new_lead_count,
       resume_view_count: resume_view_count,
       resume_download_count: resume_download_count,
       estimate_count: estimate_count,
       new_estimate_count: new_estimate_count,
       environment: runtime_environment(),
       app_version: current_app_version()
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <AdminLayouts.admin
      flash={@flash}
      current_user={@current_user}
      current_path={@current_path}
    >
      <:page_title>Dashboard</:page_title>

      <div class="space-y-8">
        <%!-- Stats grid --%>
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-7">
          <.stat_card
            id="dashboard-total-visitors"
            title="Total Visitors"
            value={@visitor_count}
            icon="hero-eye"
            href={~p"/admin/visitors"}
          />
          <.stat_card
            id="dashboard-total-leads"
            title="Total Leads"
            value={@lead_count}
            icon="hero-inbox"
            href={~p"/admin/leads"}
          />
          <.stat_card
            id="dashboard-new-leads"
            title="New Leads"
            value={@new_lead_count}
            icon="hero-envelope"
            color="yellow"
            href={~p"/admin/leads?status=new"}
          />
          <.stat_card
            id="dashboard-resume-views"
            title="Resume Views"
            value={@resume_view_count}
            icon="hero-document-magnifying-glass"
            color="amber"
            href={~p"/admin/visitors?filter=has_resume_views"}
          />
          <.stat_card
            id="dashboard-resume-downloads"
            title="Resume Downloads"
            value={@resume_download_count}
            icon="hero-arrow-down-tray"
            color="amber"
            href={~p"/admin/visitors?filter=has_resume_downloads"}
          />
          <.stat_card
            id="dashboard-total-estimates"
            title="Total Estimates"
            value={@estimate_count}
            icon="hero-document-text"
            href={~p"/admin/estimates"}
          />
          <.stat_card
            id="dashboard-new-estimates"
            title="New Estimates"
            value={@new_estimate_count}
            icon="hero-document-plus"
            color="yellow"
            href={~p"/admin/estimates?status=new"}
          />
        </div>

        <%!-- Quick actions --%>
        <div class="grid grid-cols-1 gap-6 lg:grid-cols-2">
          <div class="rounded-xl border border-white/10 bg-gray-800 p-6">
            <h3 class="text-lg font-semibold text-white mb-4">Quick Actions</h3>
            <div class="space-y-3">
              <.link
                navigate={~p"/admin/leads"}
                class="flex items-center gap-3 rounded-lg bg-gray-700/50 p-3 text-sm text-gray-200 hover:bg-gray-700 transition-colors"
              >
                <.icon name="hero-inbox" class="size-5 text-indigo-400" /> View all leads
                <.icon name="hero-arrow-right" class="size-4 ml-auto text-gray-500" />
              </.link>
              <.link
                navigate={~p"/admin/estimates"}
                class="flex items-center gap-3 rounded-lg bg-gray-700/50 p-3 text-sm text-gray-200 hover:bg-gray-700 transition-colors"
              >
                <.icon name="hero-document-text" class="size-5 text-indigo-400" />
                View all estimate requests
                <.icon name="hero-arrow-right" class="size-4 ml-auto text-gray-500" />
              </.link>
              <.link
                navigate={~p"/admin/visitors"}
                class="flex items-center gap-3 rounded-lg bg-gray-700/50 p-3 text-sm text-gray-200 hover:bg-gray-700 transition-colors"
              >
                <.icon name="hero-eye" class="size-5 text-indigo-400" /> View all visitors
                <.icon name="hero-arrow-right" class="size-4 ml-auto text-gray-500" />
              </.link>
              <.link
                navigate={~p"/"}
                class="flex items-center gap-3 rounded-lg bg-gray-700/50 p-3 text-sm text-gray-200 hover:bg-gray-700 transition-colors"
              >
                <.icon name="hero-globe-alt" class="size-5 text-indigo-400" /> View public site
                <.icon name="hero-arrow-right" class="size-4 ml-auto text-gray-500" />
              </.link>
            </div>
          </div>

          <div class="rounded-xl border border-white/10 bg-gray-800 p-6">
            <h3 class="text-lg font-semibold text-white mb-4">System Info</h3>
            <dl class="space-y-3 text-sm">
              <div class="flex justify-between">
                <dt class="text-gray-400">Single Admin Mode</dt>
                <dd class="text-gray-200">
                  {if Application.get_env(:revstack, :single_admin_mode, true),
                    do: "Enabled",
                    else: "Disabled"}
                </dd>
              </div>
              <div class="flex justify-between">
                <dt class="text-gray-400">Environment</dt>
                <dd id="dashboard-system-environment" class="text-gray-200">{@environment}</dd>
              </div>
              <div class="flex justify-between">
                <dt class="text-gray-400">Version</dt>
                <dd id="dashboard-system-app-version" class="text-gray-200">{@app_version}</dd>
              </div>
              <div class="flex justify-between">
                <dt class="text-gray-400">Phoenix</dt>
                <dd class="text-gray-200">{Application.spec(:phoenix, :vsn)}</dd>
              </div>
              <div class="flex justify-between">
                <dt class="text-gray-400">Elixir</dt>
                <dd class="text-gray-200">{System.version()}</dd>
              </div>
            </dl>
          </div>
        </div>
      </div>
    </AdminLayouts.admin>
    """
  end

  attr :title, :string, required: true
  attr :value, :integer, required: true
  attr :icon, :string, required: true
  attr :color, :string, default: "indigo"
  attr :href, :string, default: nil
  attr :id, :string, default: nil

  defp stat_card(assigns) do
    ~H"""
    <.link
      id={@id}
      navigate={@href}
      class="group rounded-xl border border-white/10 bg-gray-800 p-6 hover:border-indigo-500/50 transition-all"
    >
      <div class="flex items-center gap-4">
        <div class={[
          "flex h-12 w-12 items-center justify-center rounded-lg",
          stat_card_bg(@color)
        ]}>
          <.icon
            name={@icon}
            class={[
              "size-6",
              stat_card_text(@color)
            ]}
          />
        </div>
        <div>
          <p class="text-2xl font-bold text-white">{@value}</p>
          <p class="text-sm text-gray-400">{@title}</p>
        </div>
      </div>
    </.link>
    """
  end

  defp runtime_environment do
    :revstack
    |> Application.get_env(:environment, :prod)
    |> to_string()
  end

  defp current_app_version do
    :revstack
    |> Application.spec(:vsn)
    |> to_string()
  end

  defp stat_card_bg("yellow"), do: "bg-yellow-500/10"
  defp stat_card_bg("amber"), do: "bg-amber-500/10"
  defp stat_card_bg(_), do: "bg-indigo-500/10"

  defp stat_card_text("yellow"), do: "text-yellow-400"
  defp stat_card_text("amber"), do: "text-amber-400"
  defp stat_card_text(_), do: "text-indigo-400"
end
