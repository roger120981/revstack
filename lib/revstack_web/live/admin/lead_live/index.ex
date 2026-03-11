defmodule RevstackWeb.Admin.LeadLive.Index do
  use RevstackWeb, :live_view

  require Ash.Query

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(
       page_title: "Leads",
       current_path: "/admin/leads",
       status_filter: "all"
     )
     |> stream(:leads, [])}
  end

  @impl true
  def handle_params(params, _uri, socket) do
    status = params["status"] || "all"

    leads =
      Revstack.Consulting.Lead
      |> maybe_filter_status(status)
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.read!(authorize?: false)

    {:noreply,
     socket
     |> assign(:status_filter, status)
     |> stream(:leads, leads, reset: true)}
  end

  @impl true
  def handle_event("filter_status", %{"status" => status}, socket) do
    leads =
      Revstack.Consulting.Lead
      |> maybe_filter_status(status)
      |> Ash.Query.sort(inserted_at: :desc)
      |> Ash.read!(authorize?: false)

    {:noreply,
     socket
     |> assign(:status_filter, status)
     |> stream(:leads, leads, reset: true)}
  end

  def handle_event("delete", %{"id" => id}, socket) do
    lead =
      Revstack.Consulting.Lead
      |> Ash.get!(id, authorize?: false)

    Ash.destroy!(lead, authorize?: false)

    {:noreply,
     socket
     |> stream_delete(:leads, lead)
     |> put_flash(:info, "Lead deleted")}
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
      <:page_title>Leads</:page_title>

      <div class="space-y-6">
        <%!-- Filters --%>
        <div class="flex flex-wrap items-center gap-3">
          <span class="text-sm text-gray-400">Filter by status:</span>
          <div class="flex gap-2">
            <.filter_button
              label="All"
              value="all"
              active={@status_filter == "all"}
            />
            <.filter_button
              label="New"
              value="new"
              active={@status_filter == "new"}
            />
            <.filter_button
              label="Contacted"
              value="contacted"
              active={@status_filter == "contacted"}
            />
            <.filter_button
              label="Closed"
              value="closed"
              active={@status_filter == "closed"}
            />
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
                    Email
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Status
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Contact Method
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium uppercase tracking-wider text-gray-400">
                    Date
                  </th>
                  <th class="px-6 py-3 text-right text-xs font-medium uppercase tracking-wider text-gray-400">
                    Actions
                  </th>
                </tr>
              </thead>
              <tbody id="leads-table" phx-update="stream" class="divide-y divide-white/5">
                <tr
                  :for={{id, lead} <- @streams.leads}
                  id={id}
                  class="hover:bg-white/5 transition-colors"
                >
                  <td class="whitespace-nowrap px-6 py-4 text-sm font-medium text-white">
                    {lead.name}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-300">
                    {lead.email}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm">
                    <.status_badge status={lead.status} />
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-300">
                    {format_contact_method(lead.preferred_contact_method)}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-sm text-gray-400">
                    {format_date(lead.inserted_at)}
                  </td>
                  <td class="whitespace-nowrap px-6 py-4 text-right text-sm">
                    <div class="flex justify-end gap-2">
                      <.link
                        navigate={~p"/admin/leads/#{lead.id}"}
                        class="text-indigo-400 hover:text-indigo-300 transition-colors"
                      >
                        View
                      </.link>
                      <button
                        phx-click="delete"
                        phx-value-id={lead.id}
                        data-confirm="Are you sure you want to delete this lead?"
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
          <div id="leads-empty" class="hidden only:block px-6 py-12 text-center text-gray-500">
            No leads found.
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

  defp format_contact_method(:email), do: "Email"
  defp format_contact_method(:phone), do: "Phone"
  defp format_contact_method(:either), do: "Either"
  defp format_contact_method(_), do: "—"

  defp format_date(nil), do: "—"

  defp format_date(dt) do
    Calendar.strftime(dt, "%b %d, %Y %H:%M")
  end
end
