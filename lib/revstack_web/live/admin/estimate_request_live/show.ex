defmodule RevstackWeb.Admin.EstimateRequestLive.Show do
  use RevstackWeb, :live_view

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    estimate =
      Revstack.Consulting.EstimateRequest
      |> Ash.get!(id, authorize?: false)

    {:ok,
     socket
     |> assign(
       page_title: "Estimate: #{estimate.name}",
       current_path: "/admin/estimates",
       estimate: estimate,
       editing?: false,
       form: nil
     )}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    case socket.assigns.live_action do
      :edit ->
        form =
          socket.assigns.estimate
          |> Ash.Changeset.for_update(:update_status, %{}, authorize?: false)
          |> to_form()

        {:noreply, assign(socket, editing?: true, form: form)}

      :show ->
        {:noreply, assign(socket, editing?: false, form: nil)}
    end
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form =
      socket.assigns.estimate
      |> Ash.Changeset.for_update(:update_status, params, authorize?: false)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("save", %{"form" => params}, socket) do
    case socket.assigns.estimate
         |> Ash.Changeset.for_update(:update_status, params, authorize?: false)
         |> Ash.update() do
      {:ok, estimate} ->
        {:noreply,
         socket
         |> assign(estimate: estimate, editing?: false, form: nil)
         |> put_flash(:info, "Estimate request updated")
         |> push_patch(to: ~p"/admin/estimates/#{estimate.id}")}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  def handle_event("cancel_edit", _params, socket) do
    {:noreply,
     socket
     |> assign(editing?: false, form: nil)
     |> push_patch(to: ~p"/admin/estimates/#{socket.assigns.estimate.id}")}
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
          <.link
            navigate={~p"/admin/estimates"}
            class="text-gray-400 hover:text-white transition-colors"
          >
            <.icon name="hero-arrow-left" class="size-5" />
          </.link>
          <span>Estimate: {@estimate.name}</span>
        </div>
      </:page_title>

      <div class="max-w-4xl space-y-6">
        <%!-- Status Edit Form --%>
        <div :if={@editing?} class="rounded-xl border border-indigo-500/30 bg-gray-800 p-6">
          <h3 class="text-lg font-semibold text-white mb-4">Update Status & Size</h3>
          <.form
            for={@form}
            id="estimate-status-form"
            phx-change="validate"
            phx-submit="save"
          >
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
                    value="in_review"
                    selected={to_string(@form[:status].value) == "in_review"}
                  >
                    In Review
                  </option>
                  <option
                    value="responded"
                    selected={to_string(@form[:status].value) == "responded"}
                  >
                    Responded
                  </option>
                  <option value="closed" selected={to_string(@form[:status].value) == "closed"}>
                    Closed
                  </option>
                </select>
              </div>
              <div>
                <label class="block text-sm font-medium text-gray-300 mb-1">
                  Internal Size Tag
                </label>
                <select
                  name={@form[:internal_size_tag].name}
                  id={@form[:internal_size_tag].id}
                  class="w-full rounded-lg border border-white/10 bg-gray-700 px-3 py-2 text-sm text-white focus:border-indigo-500 focus:ring-indigo-500"
                >
                  <option value="" selected={is_nil(@form[:internal_size_tag].value)}>—</option>
                  <option
                    value="small"
                    selected={to_string(@form[:internal_size_tag].value) == "small"}
                  >
                    Small
                  </option>
                  <option
                    value="medium"
                    selected={to_string(@form[:internal_size_tag].value) == "medium"}
                  >
                    Medium
                  </option>
                  <option
                    value="large"
                    selected={to_string(@form[:internal_size_tag].value) == "large"}
                  >
                    Large
                  </option>
                  <option
                    value="unknown"
                    selected={to_string(@form[:internal_size_tag].value) == "unknown"}
                  >
                    Unknown
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
            patch={~p"/admin/estimates/#{@estimate.id}/edit"}
            class="rounded-lg bg-indigo-600 px-4 py-2 text-sm font-semibold text-white shadow hover:bg-indigo-500 transition-colors"
          >
            <.icon name="hero-pencil-square" class="size-4 inline mr-1" /> Edit Status
          </.link>
          <.link
            navigate={~p"/admin/estimates"}
            class="rounded-lg border border-white/10 bg-gray-700 px-4 py-2 text-sm font-semibold text-gray-300 hover:text-white hover:bg-gray-600 transition-colors"
          >
            Back to Estimates
          </.link>
        </div>

        <%!-- Contact Info --%>
        <div class="rounded-xl border border-white/10 bg-gray-800 overflow-hidden">
          <div class="border-b border-white/10 px-6 py-4">
            <h3 class="text-lg font-semibold text-white">Contact Information</h3>
          </div>
          <dl class="divide-y divide-white/5">
            <.detail_row label="Name" value={@estimate.name} />
            <.detail_row label="Email" value={@estimate.email} />
            <.detail_row label="Company" value={@estimate.company || "—"} />
            <.detail_row label="Source" value={@estimate.source || "—"} />
          </dl>
        </div>

        <%!-- Project Details --%>
        <div class="rounded-xl border border-white/10 bg-gray-800 overflow-hidden">
          <div class="border-b border-white/10 px-6 py-4">
            <h3 class="text-lg font-semibold text-white">Project Details</h3>
          </div>
          <dl class="divide-y divide-white/5">
            <.detail_row label="Project Type" value={format_project_type(@estimate.project_type)} />
            <.detail_row label="Budget Range" value={format_budget(@estimate.budget_range)} />
            <.detail_row label="Timeline" value={format_timeline(@estimate.timeline)} />
          </dl>
        </div>

        <%!-- Status & Metadata --%>
        <div class="rounded-xl border border-white/10 bg-gray-800 overflow-hidden">
          <div class="border-b border-white/10 px-6 py-4">
            <h3 class="text-lg font-semibold text-white">Status & Metadata</h3>
          </div>
          <dl class="divide-y divide-white/5">
            <div class="px-6 py-4 sm:grid sm:grid-cols-3 sm:gap-4">
              <dt class="text-sm font-medium text-gray-400">Status</dt>
              <dd class="mt-1 text-sm text-gray-200 sm:col-span-2 sm:mt-0">
                <.status_badge status={@estimate.status} />
              </dd>
            </div>
            <.detail_row label="Internal Size" value={format_size(@estimate.internal_size_tag)} />
            <.detail_row label="Created" value={format_date(@estimate.inserted_at)} />
            <.detail_row label="Updated" value={format_date(@estimate.updated_at)} />
          </dl>
        </div>

        <%!-- Summary --%>
        <div class="rounded-xl border border-white/10 bg-gray-800 overflow-hidden">
          <div class="border-b border-white/10 px-6 py-4">
            <h3 class="text-lg font-semibold text-white">Summary</h3>
          </div>
          <div class="px-6 py-4">
            <p class="text-sm text-gray-300 whitespace-pre-wrap">{@estimate.summary}</p>
          </div>
        </div>

        <%!-- Additional Details --%>
        <div
          :if={@estimate.details && @estimate.details != ""}
          class="rounded-xl border border-white/10 bg-gray-800 overflow-hidden"
        >
          <div class="border-b border-white/10 px-6 py-4">
            <h3 class="text-lg font-semibold text-white">Additional Details</h3>
          </div>
          <div class="px-6 py-4">
            <p class="text-sm text-gray-300 whitespace-pre-wrap">{@estimate.details}</p>
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

  defp format_project_type(:phoenix_liveview_app), do: "Phoenix/LiveView App"
  defp format_project_type(:api_backend), do: "API Backend"
  defp format_project_type(:erlang_service), do: "Erlang Service"
  defp format_project_type(:modernization), do: "Modernization"
  defp format_project_type(:devops_reliability), do: "DevOps/Reliability"
  defp format_project_type(:other), do: "Other"
  defp format_project_type(type) when is_atom(type), do: Phoenix.Naming.humanize(type)
  defp format_project_type(type), do: to_string(type)

  defp format_budget(:under_5k), do: "Under $5K"
  defp format_budget(:"5k_15k"), do: "$5K–$15K"
  defp format_budget(:"15k_50k"), do: "$15K–$50K"
  defp format_budget(:"50k_plus"), do: "$50K+"
  defp format_budget(:unknown), do: "Unknown"
  defp format_budget(nil), do: "—"
  defp format_budget(budget), do: to_string(budget)

  defp format_timeline(:asap), do: "ASAP"
  defp format_timeline(:"1_2_months"), do: "1–2 Months"
  defp format_timeline(:"3_6_months"), do: "3–6 Months"
  defp format_timeline(:flexible), do: "Flexible"
  defp format_timeline(nil), do: "—"
  defp format_timeline(timeline), do: to_string(timeline)

  defp format_size(:small), do: "Small"
  defp format_size(:medium), do: "Medium"
  defp format_size(:large), do: "Large"
  defp format_size(:unknown), do: "Unknown"
  defp format_size(nil), do: "—"
  defp format_size(size), do: to_string(size)

  defp format_date(nil), do: "—"
  defp format_date(dt), do: Calendar.strftime(dt, "%b %d, %Y at %H:%M UTC")
end
