defmodule RevstackWeb.EstimateLive do
  use RevstackWeb, :live_view

  @project_type_options [
    {"BEAM Consulting", "beam_consulting"},
    {"Phoenix / LiveView Application", "phoenix_liveview_application"},
    {"Custom Web Application", "custom_web_application"},
    {"Distributed System Architecture", "distributed_system_architecture"},
    {"Production Debugging / Reliability", "production_debugging_reliability"},
    {"Gaming PC Build", "gaming_pc_build"},
    {"Small Business Network Setup", "small_business_network_setup"},
    {"Technology Consulting", "technology_consulting"},
    {"Other", "other"}
  ]

  @impl true
  def mount(_params, session, socket) do
    form =
      Revstack.Consulting.EstimateRequest
      |> AshPhoenix.Form.for_create(:create,
        forms: [auto?: true]
      )
      |> to_form()

    {:ok,
     socket
     |> assign(page_title: "Request an Estimate — Revstack")
     |> assign(form: form)
     |> assign(project_type_options: @project_type_options)
     |> assign(visitor_ip: session["visitor_ip"])
     |> assign(visitor_user_agent: session["visitor_user_agent"])}
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
    # Inject visitor tracking context into form params
    params =
      params
      |> Map.put("request_ip", socket.assigns.visitor_ip)
      |> Map.put("request_user_agent", socket.assigns.visitor_user_agent)

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
      <section class="pb-16 pt-6 sm:pb-24 sm:pt-10">
        <div class="mx-auto max-w-2xl">
          <div class="mx-auto mb-10 max-w-3xl text-center sm:mb-12">
            <div class="flex justify-center">
              <img
                id="estimate-page-logo"
                src="/images/revenuelink_main.png"
                alt="RevenueLink Technologies"
                class="h-auto w-full max-w-[230px] opacity-95 sm:max-w-[290px] lg:max-w-[340px]"
              />
            </div>
            <div class="mt-5 inline-flex items-center gap-2 rounded-full bg-primary/10 px-4 py-1.5 text-sm font-medium text-primary">
              <.icon name="hero-document-text" class="size-4" /> Project Inquiry
            </div>
            <h1 class="mt-4 text-4xl font-extrabold tracking-tight text-base-content sm:text-5xl">
              Request an <span class="text-primary">Estimate</span>
            </h1>
            <div class="mt-4 w-16 h-1 bg-primary mx-auto rounded-full"></div>
            <p
              id="estimate-intro-copy"
              class="mx-auto mt-6 max-w-2xl text-lg leading-relaxed text-base-content/70"
            >
              Tell me about the consulting, application, or local technology work you are considering and I&apos;ll respond with a tailored next-step recommendation.
            </p>
            <div class="mt-5 flex flex-wrap items-center justify-center gap-2 text-xs font-medium text-base-content/60">
              <span class="rounded-full bg-base-200 px-3 py-1">BEAM consulting</span>
              <span class="rounded-full bg-base-200 px-3 py-1">Custom applications</span>
              <span class="rounded-full bg-base-200 px-3 py-1">Local technology projects</span>
            </div>
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
                options={@project_type_options}
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
