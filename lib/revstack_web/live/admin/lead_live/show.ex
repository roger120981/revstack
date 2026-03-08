defmodule RevstackWeb.Admin.LeadLive.Show do
  use RevstackWeb, :live_view

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    lead =
      Revstack.Consulting.Lead
      |> Ash.get!(id, authorize?: false)

    {:ok,
     socket
     |> assign(
       page_title: "Lead: #{lead.name}",
       current_path: "/admin/leads",
       lead: lead,
       editing?: false,
       form: nil
     )}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    case socket.assigns.live_action do
      :edit ->
        form =
          socket.assigns.lead
          |> AshPhoenix.Form.for_update(:update_status,
            as: "form",
            authorize?: false
          )
          |> to_form()

        {:noreply, assign(socket, editing?: true, form: form)}

      :show ->
        {:noreply, assign(socket, editing?: false, form: nil)}
    end
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form =
      socket.assigns.form.source
      |> AshPhoenix.Form.validate(params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form.source, params: params) do
      {:ok, lead} ->
        {:noreply,
         socket
         |> assign(lead: lead, editing?: false, form: nil)
         |> put_flash(:info, "Lead updated")
         |> push_patch(to: ~p"/admin/leads/#{lead.id}")}

      {:error, form} ->
        {:noreply, assign(socket, form: to_form(form))}
    end
  end

  def handle_event("cancel_edit", _params, socket) do
    {:noreply,
     socket
     |> assign(editing?: false, form: nil)
     |> push_patch(to: ~p"/admin/leads/#{socket.assigns.lead.id}")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <AdminLayouts.admin
      flash={@flash}
      current_user={@current_user}
      current_path={@current_path}
    >
      <:page_title>
        <div class="flex items-center gap-3">
          <.link navigate={~p"/admin/leads"} class="text-gray-400 hover:text-white transition-colors">
            <.icon name="hero-arrow-left" class="size-5" />
          </.link>
          <span>Lead: {@lead.name}</span>
        </div>
      </:page_title>

      <div class="max-w-4xl space-y-6">
        <%!-- Status Edit Form --%>
        <div :if={@editing?} class="rounded-xl border border-indigo-500/30 bg-gray-800 p-6">
          <h3 class="text-lg font-semibold text-white mb-4">Update Status</h3>
          <.form for={@form} id="lead-status-form" phx-change="validate" phx-submit="save">
            <div class="grid grid-cols-1 gap-4 sm:grid-cols-2">
              <div>
                <label class="block text-sm font-medium text-gray-300 mb-1">Status</label>
                <select
                  name={@form[:status].name}
                  id={@form[:status].id}
                  class="w-full rounded-lg border border-white/10 bg-gray-700 px-3 py-2 text-sm text-white focus:border-indigo-500 focus:ring-indigo-500"
                >
                  <option value="new" selected={to_string(@form[:status].value) == "new"}>
                    New
                  </option>
                  <option
                    value="contacted"
                    selected={to_string(@form[:status].value) == "contacted"}
                  >
                    Contacted
                  </option>
                  <option value="closed" selected={to_string(@form[:status].value) == "closed"}>
                    Closed
                  </option>
                </select>
              </div>
            </div>
            <div class="mt-4 flex gap-3">
              <button
                type="submit"
                class="rounded-lg bg-indigo-600 px-4 py-2 text-sm font-semibold text-white shadow hover:bg-indigo-500 transition-colors"
              >
                Save Changes
              </button>
              <button
                type="button"
                phx-click="cancel_edit"
                class="rounded-lg border border-white/10 bg-gray-700 px-4 py-2 text-sm font-semibold text-gray-300 hover:text-white hover:bg-gray-600 transition-colors"
              >
                Cancel
              </button>
            </div>
          </.form>
        </div>

        <%!-- Actions bar --%>
        <div :if={!@editing?} class="flex gap-3">
          <.link
            patch={~p"/admin/leads/#{@lead.id}/edit"}
            class="rounded-lg bg-indigo-600 px-4 py-2 text-sm font-semibold text-white shadow hover:bg-indigo-500 transition-colors"
          >
            <.icon name="hero-pencil-square" class="size-4 inline mr-1" /> Edit Status
          </.link>
          <.link
            navigate={~p"/admin/leads"}
            class="rounded-lg border border-white/10 bg-gray-700 px-4 py-2 text-sm font-semibold text-gray-300 hover:text-white hover:bg-gray-600 transition-colors"
          >
            Back to Leads
          </.link>
        </div>

        <%!-- Lead details --%>
        <div class="rounded-xl border border-white/10 bg-gray-800 overflow-hidden">
          <div class="border-b border-white/10 px-6 py-4">
            <h3 class="text-lg font-semibold text-white">Contact Information</h3>
          </div>
          <dl class="divide-y divide-white/5">
            <.detail_row label="Name" value={@lead.name} />
            <.detail_row label="Email" value={@lead.email} />
            <.detail_row label="Company" value={@lead.company || "—"} />
            <.detail_row label="Phone" value={@lead.phone || "—"} />
            <.detail_row
              label="Preferred Contact"
              value={format_contact_method(@lead.preferred_contact_method)}
            />
            <.detail_row label="Source" value={@lead.source || "—"} />
          </dl>
        </div>

        <div class="rounded-xl border border-white/10 bg-gray-800 overflow-hidden">
          <div class="border-b border-white/10 px-6 py-4">
            <h3 class="text-lg font-semibold text-white">Status & Metadata</h3>
          </div>
          <dl class="divide-y divide-white/5">
            <div class="px-6 py-4 sm:grid sm:grid-cols-3 sm:gap-4">
              <dt class="text-sm font-medium text-gray-400">Status</dt>
              <dd class="mt-1 text-sm text-gray-200 sm:col-span-2 sm:mt-0">
                <.status_badge status={@lead.status} />
              </dd>
            </div>
            <.detail_row label="Created" value={format_date(@lead.inserted_at)} />
            <.detail_row label="Updated" value={format_date(@lead.updated_at)} />
          </dl>
        </div>

        <div class="rounded-xl border border-white/10 bg-gray-800 overflow-hidden">
          <div class="border-b border-white/10 px-6 py-4">
            <h3 class="text-lg font-semibold text-white">Message</h3>
          </div>
          <div class="px-6 py-4">
            <p class="text-sm text-gray-300 whitespace-pre-wrap">{@lead.message}</p>
          </div>
        </div>
      </div>
    </AdminLayouts.admin>
    """
  end

  attr :label, :string, required: true
  attr :value, :string, required: true

  defp detail_row(assigns) do
    ~H"""
    <div class="px-6 py-4 sm:grid sm:grid-cols-3 sm:gap-4">
      <dt class="text-sm font-medium text-gray-400">{@label}</dt>
      <dd class="mt-1 text-sm text-gray-200 sm:col-span-2 sm:mt-0">{@value}</dd>
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
  defp status_color(_), do: "bg-gray-400/10 text-gray-400"

  defp format_status(:new), do: "New"
  defp format_status(:contacted), do: "Contacted"
  defp format_status(:closed), do: "Closed"
  defp format_status(status) when is_atom(status), do: Phoenix.Naming.humanize(status)
  defp format_status(status), do: to_string(status)

  defp format_contact_method(:email), do: "Email"
  defp format_contact_method(:phone), do: "Phone"
  defp format_contact_method(:either), do: "Either"
  defp format_contact_method(_), do: "—"

  defp format_date(nil), do: "—"
  defp format_date(dt), do: Calendar.strftime(dt, "%b %d, %Y at %H:%M UTC")
end
