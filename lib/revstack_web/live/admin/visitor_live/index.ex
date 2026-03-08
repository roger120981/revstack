defmodule RevstackWeb.Admin.VisitorLive.Index do
  use RevstackWeb, :live_view

  require Ash.Query

  @impl true
  def mount(_params, _session, socket) do
    visitors = list_visitors("all")

    {:ok,
     socket
     |> assign(
       page_title: "Visitors",
       current_path: "/admin/visitors",
       filter: "all",
       visitors_empty?: visitors == []
     )
     |> stream(:visitors, visitors)}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("filter", %{"filter" => filter}, socket) do
    visitors = list_visitors(filter)

    {:noreply,
     socket
     |> assign(:filter, filter)
     |> assign(:visitors_empty?, visitors == [])
     |> stream(:visitors, visitors, reset: true)}
  end

  defp list_visitors(filter) do
    Revstack.Tracking.Visitor
    |> Ash.Query.sort(last_visited_at: :desc)
    |> Ash.Query.load([:lead_count, :estimate_count])
    |> maybe_apply_filter(filter)
    |> Ash.read!(authorize?: false)
  end

  defp maybe_apply_filter(query, "all"), do: query

  defp maybe_apply_filter(query, "has_leads") do
    Ash.Query.filter(query, lead_count > 0)
  end

  defp maybe_apply_filter(query, "has_estimates") do
    Ash.Query.filter(query, estimate_count > 0)
  end

  defp maybe_apply_filter(query, "recent") do
    cutoff = DateTime.add(DateTime.utc_now(), -7, :day)
    Ash.Query.filter(query, last_visited_at > ^cutoff)
  end

  defp maybe_apply_filter(query, _), do: query

  @impl true
  def render(assigns) do
    ~H"""
    <AdminLayouts.admin
      flash={@flash}
      current_user={@current_user}
      current_path={@current_path}
    >
      <:page_title>Visitors</:page_title>

      <div class="space-y-6">
        <%!-- Filters --%>
        <div class="flex flex-wrap items-center gap-3">
          <span class="text-sm text-gray-400">Filter:</span>
          <div class="flex gap-2">
            <.filter_button label="All" value="all" active={@filter == "all"} />
            <.filter_button label="Has Leads" value="has_leads" active={@filter == "has_leads"} />
            <.filter_button
              label="Has Estimates"
              value="has_estimates"
              active={@filter == "has_estimates"}
            />
            <.filter_button label="Last 7 Days" value="recent" active={@filter == "recent"} />
          </div>
        </div>

        <%!-- Table --%>
        <div class="rounded-xl border border-white/10 bg-gray-800 overflow-hidden">
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-white/10">
              <thead class="bg-gray-800/50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    IP Address
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Location
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    User Agent
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    First Visit
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Last Visit
                  </th>
                  <th class="px-6 py-3 text-center text-xs font-medium uppercase tracking-wider text-gray-400">
                    Visits
                  </th>
                  <th class="px-6 py-3 text-center text-xs font-medium uppercase tracking-wider text-gray-400">
                    Leads
                  </th>
                  <th class="px-6 py-3 text-center text-xs font-medium uppercase tracking-wider text-gray-400">
                    Estimates
                  </th>
                  <th class="px-6 py-3 text-right text-xs font-medium uppercase tracking-wider text-gray-400">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody id="visitors-table" phx-update="stream" class="divide-y divide-white/5">
                <tr
                  :for={{id, visitor} <- @streams.visitors}
                  id={id}
                  class="hover:bg-white/5 transition-colors"
                >
                  <td class="whitespace-nowrap px-6 py-4 text-sm font-mono font-medium text-white">
                    {visitor.ip_address}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-300">
                    {format_location(visitor)}
                  </td>
                  <td
                    class="max-w-[200px] truncate px-6 py-4 text-sm text-gray-400"
                    title={visitor.user_agent}
                  >
                    {truncate_ua(visitor.user_agent)}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-400">
                    {format_date(visitor.first_visited_at)}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-400">
                    {format_date(visitor.last_visited_at)}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-center text-sm text-gray-300">
                    {visitor.visit_count}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-center text-sm">
                    <span
                      :if={visitor.lead_count > 0}
                      class="inline-flex items-center rounded-full bg-green-400/10 px-2 py-0.5 text-xs font-medium text-green-400"
                    >
                      {visitor.lead_count}
                    </span>
                    <span :if={visitor.lead_count == 0} class="text-gray-600">0</span>
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-center text-sm">
                    <span
                      :if={visitor.estimate_count > 0}
                      class="inline-flex items-center rounded-full bg-blue-400/10 px-2 py-0.5 text-xs font-medium text-blue-400"
                    >
                      {visitor.estimate_count}
                    </span>
                    <span :if={visitor.estimate_count == 0} class="text-gray-600">0</span>
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-right text-sm">
                    <.link
                      navigate={~p"/admin/visitors/#{visitor.id}"}
                      class="text-indigo-400 hover:text-indigo-300 transition-colors"
                    >
                      View
                    </.link>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          <div
            :if={@visitors_empty?}
            class="px-6 py-12 text-center text-gray-500"
          >
            No visitors found.
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
      phx-click="filter"
      phx-value-filter={@value}
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

  defp format_location(visitor) do
    parts =
      [visitor.ip_location_city, visitor.ip_location_region, visitor.ip_location_country]
      |> Enum.reject(&is_nil/1)
      |> Enum.reject(&(&1 == ""))

    case parts do
      [] -> "—"
      parts -> Enum.join(parts, ", ")
    end
  end

  defp truncate_ua(nil), do: "—"

  defp truncate_ua(ua) do
    if String.length(ua) > 50 do
      String.slice(ua, 0, 50) <> "…"
    else
      ua
    end
  end

  defp format_date(nil), do: "—"

  defp format_date(dt) do
    Calendar.strftime(dt, "%b %d, %Y %H:%M")
  end
end
