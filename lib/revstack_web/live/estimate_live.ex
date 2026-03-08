defmodule RevstackWeb.EstimateLive do
  use RevstackWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    form =
      Revstack.Consulting.EstimateRequest
      |> AshPhoenix.Form.for_create(:create,
        forms: [auto?: true]
      )
      |> to_form()

    {:ok,
     socket
     |> assign(page_title: "Request an Estimate — Revstack")
     |> assign(form: form)}
  end

  @impl true
  def handle_event("validate", %{"form" => params}, socket) do
    form =
      AshPhoenix.Form.validate(socket.assigns.form.source, params)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  @impl true
  def handle_event("submit", %{"form" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form.source, params: params) do
      {:ok, _estimate} ->
        {:noreply,
         socket
         |> put_flash(
           :info,
           "Estimate request received! I'll review it and get back to you soon."
         )
         |> push_navigate(to: ~p"/thanks")}

      {:error, form} ->
        {:noreply, assign(socket, form: to_form(form))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={assigns[:current_user]}>
      <section class="py-16 sm:py-24">
        <div class="mx-auto max-w-2xl">
          <div class="text-center mb-12">
            <h1 class="text-4xl sm:text-5xl font-extrabold tracking-tight text-base-content">
              Request an <span class="text-primary">Estimate</span>
            </h1>
            <div class="mt-4 w-16 h-1 bg-primary mx-auto rounded-full"></div>
            <p class="mt-6 text-lg text-base-content/70 leading-relaxed">
              Tell me about your project and I'll put together a tailored proposal.
            </p>
          </div>

          <div class="rounded-2xl border border-base-300 bg-base-100 p-6 sm:p-8 shadow-sm">
            <.form
              for={@form}
              id="estimate-form"
              phx-change="validate"
              phx-submit="submit"
              class="space-y-1"
            >
              <.input field={@form[:name]} label="Name" placeholder="Your full name" required />
              <.input
                field={@form[:email]}
                type="email"
                label="Email"
                placeholder="you@example.com"
                required
              />
              <.input field={@form[:company]} label="Company" placeholder="Optional" />

              <.input
                field={@form[:project_type]}
                type="select"
                label="Project Type"
                prompt="Select a project type..."
                options={[
                  {"Phoenix LiveView App", "phoenix_liveview_app"},
                  {"API Backend", "api_backend"},
                  {"Erlang Service", "erlang_service"},
                  {"Modernization", "modernization"},
                  {"DevOps & Reliability", "devops_reliability"},
                  {"Other", "other"}
                ]}
                required
              />

              <.input
                field={@form[:budget_range]}
                type="select"
                label="Budget Range"
                prompt="Select a budget range..."
                options={[
                  {"Under $5K", "under_5k"},
                  {"$5K – $15K", "5k_15k"},
                  {"$15K – $50K", "15k_50k"},
                  {"$50K+", "50k_plus"},
                  {"Not sure yet", "unknown"}
                ]}
              />

              <.input
                field={@form[:timeline]}
                type="select"
                label="Timeline"
                prompt="Select a timeline..."
                options={[
                  {"ASAP", "asap"},
                  {"1–2 months", "1_2_months"},
                  {"3–6 months", "3_6_months"},
                  {"Flexible", "flexible"}
                ]}
              />

              <.input
                field={@form[:summary]}
                type="textarea"
                label="Project Summary"
                placeholder="Brief overview of what you need (at least 30 characters)..."
                rows="4"
                required
              />

              <.input
                field={@form[:details]}
                type="textarea"
                label="Additional Details"
                placeholder="Any additional context, requirements, or questions..."
                rows="4"
              />

              <.input field={@form[:source]} type="hidden" value="website" />

              <div class="pt-4">
                <button
                  type="submit"
                  class="btn btn-primary btn-lg w-full gap-2 shadow-lg hover:shadow-xl transition-all duration-300"
                >
                  <.icon name="hero-paper-airplane" class="size-5" /> Submit Estimate Request
                </button>
              </div>
            </.form>
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end
end
