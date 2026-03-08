defmodule RevstackWeb.Admin.VisitorLive.Show do
  use RevstackWeb, :live_view

  require Ash.Query

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    visitor =
      Revstack.Tracking.Visitor
      |> Ash.get!(id,
        authorize?: false,
        load: [:lead_count, :estimate_count, :page_visits, :leads, :estimate_requests]
      )

    page_visits =
      Revstack.Tracking.VisitorPageVisit
      |> Ash.Query.filter(visitor_id == ^visitor.id)
      |> Ash.Query.sort(visited_at: :desc)
      |> Ash.read!(authorize?: false)

    leads =
      Revstack.Consulting.Lead
      |> Ash.Query.filter(request_ip == ^visitor.ip_address)
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.read!(authorize?: false)

    estimates =
      Revstack.Consulting.EstimateRequest
      |> Ash.Query.filter(request_ip == ^visitor.ip_address)
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.read!(authorize?: false)

    {:ok,
     socket
     |> assign(
       page_title: "Visitor: #{visitor.ip_address}",
       current_path: "/admin/visitors/#{id}",
       visitor: visitor,
       leads: leads,
       estimates: estimates
     )
     |> stream(:page_visits, page_visits)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <AdminLayouts.admin
      flash={@flash}
      current_user={@current_user}
      current_path={@current_path}
    >
      <:page_title>Visitor Detail</:page_title>
      <:page_actions>
        <.link
          navigate={~p"/admin/visitors"}
          class="rounded-lg bg-gray-700 px-4 py-2 text-sm font-medium text-gray-200 hover:bg-gray-600 transition-colors"
        >
          <.icon name="hero-arrow-left" class="size-4 mr-1" /> Back to Visitors
        </.link>
      </:page_actions>

      <div class="space-y-8">
        <%!-- Visitor summary --%>
        <div id="visitor-summary" class="rounded-xl border border-white/10 bg-gray-800 p-6">
          <h2 class="text-lg font-semibold text-white mb-6 flex items-center gap-2">
            <.icon name="hero-user" class="size-5 text-indigo-400" /> Visitor Summary
          </h2>
          <dl class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">
            <.detail_item label="IP Address" value={@visitor.ip_address} mono />
            <.detail_item label="Location" value={format_location(@visitor)} />
            <.detail_item label="User Agent" value={@visitor.user_agent || "—"} />
            <.detail_item label="Referrer" value={@visitor.referrer || "—"} />
            <.detail_item label="First Visited" value={format_date(@visitor.first_visited_at)} />
            <.detail_item label="Last Visited" value={format_date(@visitor.last_visited_at)} />
            <.detail_item label="Total Visits" value={to_string(@visitor.visit_count)} />
            <.detail_item label="Leads Submitted" value={to_string(@visitor.lead_count)} />
            <.detail_item label="Estimates Submitted" value={to_string(@visitor.estimate_count)} />
          </dl>
        </div>

        <%!-- Conversion status --%>
        <div class="grid grid-cols-1 gap-5 sm:grid-cols-3">
          <div
            id="visitor-conversion-visits"
            class={[
              "rounded-xl border p-5 text-center",
              "border-white/10 bg-gray-800"
            ]}
          >
            <p class="text-3xl font-bold text-white">{@visitor.visit_count}</p>
            <p class="text-sm text-gray-400 mt-1">Page Views</p>
          </div>
          <div
            id="visitor-conversion-leads"
            class={[
              "rounded-xl border p-5 text-center",
              if(@visitor.lead_count > 0,
                do: "border-green-500/30 bg-green-900/20",
                else: "border-white/10 bg-gray-800"
              )
            ]}
          >
            <p class={[
              "text-3xl font-bold",
              if(@visitor.lead_count > 0, do: "text-green-400", else: "text-white")
            ]}>
              {@visitor.lead_count}
            </p>
            <p class="text-sm text-gray-400 mt-1">Lead Submissions</p>
          </div>
          <div
            id="visitor-conversion-estimates"
            class={[
              "rounded-xl border p-5 text-center",
              if(@visitor.estimate_count > 0,
                do: "border-blue-500/30 bg-blue-900/20",
                else: "border-white/10 bg-gray-800"
              )
            ]}
          >
            <p class={[
              "text-3xl font-bold",
              if(@visitor.estimate_count > 0, do: "text-blue-400", else: "text-white")
            ]}>
              {@visitor.estimate_count}
            </p>
            <p class="text-sm text-gray-400 mt-1">Estimate Requests</p>
          </div>
        </div>

        <%!-- Page visit history --%>
        <div class="rounded-xl border border-white/10 bg-gray-800 overflow-hidden">
          <div class="px-6 py-4 border-b border-white/10">
            <h2 class="text-lg font-semibold text-white flex items-center gap-2">
              <.icon name="hero-document-text" class="size-5 text-indigo-400" /> Page Visit History
            </h2>
          </div>
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-white/10">
              <thead class="bg-gray-800/50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Path
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Visited At
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Query String
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Method
                  </th>
                </tr>
              </thead>
              <tbody id="page-visits-table" phx-update="stream" class="divide-y divide-white/5">
                <tr
                  :for={{id, visit} <- @streams.page_visits}
                  id={id}
                  class="hover:bg-white/5 transition-colors"
                >
                  <td class="whitespace-nowrap px-6 py-4 text-sm font-mono text-indigo-300">
                    {visit.path}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-400">
                    {format_datetime(visit.visited_at)}
                  </td>
                  <td class="max-w-[200px] truncate px-6 py-4 text-sm text-gray-500">
                    {visit.query_string || "—"}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-500">
                    {visit.method || "—"}
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <div class="hidden only:block px-6 py-8 text-center text-gray-500">
            No page visits recorded.
          </div>
        </div>

        <%!-- Related leads --%>
        <div :if={@leads != []} class="rounded-xl border border-white/10 bg-gray-800 overflow-hidden">
          <div class="px-6 py-4 border-b border-white/10">
            <h2 class="text-lg font-semibold text-white flex items-center gap-2">
              <.icon name="hero-inbox" class="size-5 text-green-400" /> Lead Submissions
            </h2>
          </div>
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-white/10">
              <thead class="bg-gray-800/50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Name
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Email
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Status
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Submitted
                  </th>
                  <th class="px-6 py-3 text-right text-xs font-medium uppercase tracking-wider text-gray-400">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody class="divide-y divide-white/5">
                <tr :for={lead <- @leads} class="hover:bg-white/5 transition-colors">
                  <td class="whitespace-nowrap px-6 py-4 text-sm font-medium text-white">
                    {lead.name}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-300">
                    {lead.email}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm">
                    <.status_badge status={lead.status} />
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-400">
                    {format_date(lead.inserted_at)}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-right text-sm">
                    <.link
                      navigate={~p"/admin/leads/#{lead.id}"}
                      class="text-indigo-400 hover:text-indigo-300 transition-colors"
                    >
                      View
                    </.link>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>

        <%!-- Related estimates --%>
        <div
          :if={@estimates != []}
          class="rounded-xl border border-white/10 bg-gray-800 overflow-hidden"
        >
          <div class="px-6 py-4 border-b border-white/10">
            <h2 class="text-lg font-semibold text-white flex items-center gap-2">
              <.icon name="hero-document-text" class="size-5 text-blue-400" />
              Estimate Request Submissions
            </h2>
          </div>
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-white/10">
              <thead class="bg-gray-800/50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Name
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Email
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Project Type
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Status
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Submitted
                  </th>
                  <th class="px-6 py-3 text-right text-xs font-medium uppercase tracking-wider text-gray-400">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody class="divide-y divide-white/5">
                <tr :for={est <- @estimates} class="hover:bg-white/5 transition-colors">
                  <td class="whitespace-nowrap px-6 py-4 text-sm font-medium text-white">
                    {est.name}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-300">
                    {est.email}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-300">
                    {format_project_type(est.project_type)}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm">
                    <.status_badge status={est.status} />
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-400">
                    {format_date(est.inserted_at)}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-right text-sm">
                    <.link
                      navigate={~p"/admin/estimates/#{est.id}"}
                      class="text-indigo-400 hover:text-indigo-300 transition-colors"
                    >
                      View
                    </.link>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </AdminLayouts.admin>
    """
  end

  attr :label, :string, required: true
  attr :value, :string, required: true
  attr :mono, :boolean, default: false

  defp detail_item(assigns) do
    ~H"""
    <div class="rounded-lg bg-gray-900/50 p-4">
      <dt class="text-xs font-medium uppercase tracking-wider text-gray-500 mb-1">{@label}</dt>
      <dd class={[
        "text-sm text-gray-200 break-all",
        @mono && "font-mono"
      ]}>
        {@value}
      </dd>
    </div>
    """
  end

  attr :status, :atom, required: true

  defp status_badge(assigns) do
    ~H"""
    <span class={[
      "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium",
      status_color(@status)
    ]}>
      {format_status(@status)}
    </span>
    """
  end

  defp status_color(:new), do: "bg-yellow-400/10 text-yellow-400"
  defp status_color(:contacted), do: "bg-blue-400/10 text-blue-400"
  defp status_color(:closed), do: "bg-gray-400/10 text-gray-400"
  defp status_color(:in_review), do: "bg-purple-400/10 text-purple-400"
  defp status_color(:responded), do: "bg-green-400/10 text-green-400"
  defp status_color(_), do: "bg-gray-400/10 text-gray-400"

  defp format_status(:new), do: "New"
  defp format_status(:contacted), do: "Contacted"
  defp format_status(:closed), do: "Closed"
  defp format_status(:in_review), do: "In Review"
  defp format_status(:responded), do: "Responded"
  defp format_status(status) when is_atom(status), do: Phoenix.Naming.humanize(status)
  defp format_status(status), do: to_string(status)

  defp format_project_type(:phoenix_liveview_app), do: "Phoenix/LiveView"
  defp format_project_type(:api_backend), do: "API Backend"
  defp format_project_type(:erlang_service), do: "Erlang/OTP"
  defp format_project_type(:modernization), do: "Modernization"
  defp format_project_type(:devops_reliability), do: "DevOps"
  defp format_project_type(:beam_consulting), do: "BEAM Consulting"
  defp format_project_type(:phoenix_liveview_application), do: "Phoenix / LiveView Application"
  defp format_project_type(:custom_web_application), do: "Custom Web Application"

  defp format_project_type(:distributed_system_architecture),
    do: "Distributed System Architecture"

  defp format_project_type(:production_debugging_reliability),
    do: "Production Debugging / Reliability"

  defp format_project_type(:gaming_pc_build), do: "Gaming PC Build"
  defp format_project_type(:small_business_network_setup), do: "Small Business Network Setup"
  defp format_project_type(:technology_consulting), do: "Technology Consulting"
  defp format_project_type(:other), do: "Other"
  defp format_project_type(type) when is_atom(type), do: Phoenix.Naming.humanize(type)
  defp format_project_type(type), do: to_string(type)

  defp format_location(visitor) do
    parts =
      [visitor.ip_location_city, visitor.ip_location_region, visitor.ip_location_country]
      |> Enum.reject(&is_nil/1)
      |> Enum.reject(&(&1 == ""))

    case parts do
      [] -> "Unknown"
      parts -> Enum.join(parts, ", ")
    end
  end

  defp format_date(nil), do: "—"

  defp format_date(dt) do
    Calendar.strftime(dt, "%b %d, %Y %H:%M")
  end

  defp format_datetime(nil), do: "—"

  defp format_datetime(dt) do
    Calendar.strftime(dt, "%b %d, %Y %H:%M:%S")
  end
end
