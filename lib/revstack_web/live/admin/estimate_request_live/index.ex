defmodule RevstackWeb.Admin.EstimateRequestLive.Index do
  use RevstackWeb, :live_view

  require Ash.Query

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       page_title: "Estimate Requests",
       current_path: "/admin/estimates",
       status_filter: "all"
     )
     |> stream(:estimates, [])}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    status = params["status"] || "all"

    estimates =
      Revstack.Consulting.EstimateRequest
      |> maybe_filter_status(status)
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.read!(authorize?: false)

    {:noreply,
     socket
     |> assign(:status_filter, status)
     |> stream(:estimates, estimates, reset: true)}
  end

  @impl true
  def handle_event("filter_status", %{"status" => status}, socket) do
    estimates =
      Revstack.Consulting.EstimateRequest
      |> maybe_filter_status(status)
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.read!(authorize?: false)

    {:noreply,
     socket
     |> assign(:status_filter, status)
     |> stream(:estimates, estimates, reset: true)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    estimate =
      Revstack.Consulting.EstimateRequest
      |> Ash.get!(id, authorize?: false)

    Ash.destroy!(estimate, authorize?: false)

    {:noreply,
     socket
     |> stream_delete(:estimates, estimate)
     |> put_flash(:info, "Estimate request deleted")}
  end

  defp maybe_filter_status(query, "all"), do: query

  defp maybe_filter_status(query, status) do
    status_atom = String.to_existing_atom(status)
    Ash.Query.filter(query, status == ^status_atom)
  end

  @impl true
  def render(assigns) do
    ~H"""
    <AdminLayouts.admin
      flash={@flash}
      current_user={@current_user}
      current_path={@current_path}
    >
      <:page_title>Estimate Requests</:page_title>

      <div class="space-y-6">
        <%!-- Filters --%>
        <div class="flex flex-wrap items-center gap-3">
          <span class="text-sm text-gray-400">Filter by status:</span>
          <div class="flex gap-2">
            <.filter_button label="All" value="all" active={@status_filter == "all"} />
            <.filter_button label="New" value="new" active={@status_filter == "new"} />
            <.filter_button
              label="In Review"
              value="in_review"
              active={@status_filter == "in_review"}
            />
            <.filter_button
              label="Responded"
              value="responded"
              active={@status_filter == "responded"}
            />
            <.filter_button label="Closed" value="closed" active={@status_filter == "closed"} />
          </div>
        </div>

        <%!-- Table --%>
        <div class="rounded-xl border border-white/10 bg-gray-800 overflow-hidden">
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-white/10">
              <thead class="bg-gray-800/50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Name
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Project Type
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Budget
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Status
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Size
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Date
                  </th>
                  <th class="px-6 py-3 text-right text-xs font-medium uppercase tracking-wider text-gray-400">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody id="estimates-table" phx-update="stream" class="divide-y divide-white/5">
                <tr
                  :for={{id, est} <- @streams.estimates}
                  id={id}
                  class="hover:bg-white/5 transition-colors"
                >
                  <td class="whitespace-nowrap px-6 py-4 text-sm font-medium text-white">
                    {est.name}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-300">
                    <.project_type_badge type={est.project_type} />
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-300">
                    {format_budget(est.budget_range)}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm">
                    <.status_badge status={est.status} />
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-300">
                    {format_size(est.internal_size_tag)}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-400">
                    {format_date(est.inserted_at)}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-right text-sm">
                    <div class="flex justify-end gap-2">
                      <.link
                        navigate={~p"/admin/estimates/#{est.id}"}
                        class="text-indigo-400 hover:text-indigo-300 transition-colors"
                      >
                        View
                      </.link>
                      <button
                        phx-click="delete"
                        phx-value-id={est.id}
                        data-confirm="Are you sure you want to delete this estimate request?"
                        class="text-red-400 hover:text-red-300 transition-colors"
                      >
                        Delete
                      </button>
                    </div>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <div
            id="estimates-empty"
            class="hidden only:block px-6 py-12 text-center text-gray-500"
          >
            No estimate requests found.
          </div>
        </div>
      </div>
    </AdminLayouts.admin>
    """
  end

  attr :label, :string, required: true
  attr :value, :string, required: true
  attr :active, :boolean, default: false

  defp filter_button(assigns) do
    ~H"""
    <button
      phx-click="filter_status"
      phx-value-status={@value}
      class={[
        "rounded-lg px-3 py-1.5 text-xs font-medium transition-colors",
        if(@active,
          do: "bg-indigo-600 text-white",
          else: "bg-gray-800 text-gray-400 hover:text-white hover:bg-gray-700 border border-white/10"
        )
      ]}
    >
      {@label}
    </button>
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
  defp status_color(:in_review), do: "bg-purple-400/10 text-purple-400"
  defp status_color(:responded), do: "bg-green-400/10 text-green-400"
  defp status_color(:closed), do: "bg-gray-400/10 text-gray-400"
  defp status_color(_), do: "bg-gray-400/10 text-gray-400"

  defp format_status(:new), do: "New"
  defp format_status(:in_review), do: "In Review"
  defp format_status(:responded), do: "Responded"
  defp format_status(:closed), do: "Closed"
  defp format_status(status) when is_atom(status), do: Phoenix.Naming.humanize(status)
  defp format_status(status), do: to_string(status)

  attr :type, :atom, required: true

  defp project_type_badge(assigns) do
    ~H"""
    <span class="inline-flex items-center rounded-full bg-indigo-400/10 px-2.5 py-0.5 text-xs font-medium text-indigo-400">
      {format_project_type(@type)}
    </span>
    """
  end

  defp format_project_type(:phoenix_liveview_app), do: "Phoenix/LiveView"
  defp format_project_type(:api_backend), do: "API Backend"
  defp format_project_type(:erlang_service), do: "Erlang Service"
  defp format_project_type(:modernization), do: "Modernization"
  defp format_project_type(:devops_reliability), do: "DevOps/Reliability"
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

  defp format_budget(:under_5k), do: "< $5K"
  defp format_budget(:"5k_15k"), do: "$5K–$15K"
  defp format_budget(:"15k_50k"), do: "$15K–$50K"
  defp format_budget(:"50k_plus"), do: "$50K+"
  defp format_budget(:unknown), do: "Unknown"
  defp format_budget(nil), do: "—"
  defp format_budget(budget), do: to_string(budget)

  defp format_size(:small), do: "Small"
  defp format_size(:medium), do: "Medium"
  defp format_size(:large), do: "Large"
  defp format_size(:unknown), do: "Unknown"
  defp format_size(nil), do: "—"
  defp format_size(size), do: to_string(size)

  defp format_date(nil), do: "—"
  defp format_date(dt), do: Calendar.strftime(dt, "%b %d, %Y %H:%M")
end
