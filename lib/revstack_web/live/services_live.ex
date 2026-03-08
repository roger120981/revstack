defmodule RevstackWeb.ServicesLive do
  use RevstackWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Services — Revstack")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={assigns[:current_user]}>
      <section class="py-16 sm:py-24">
        <div class="mx-auto max-w-5xl">
          <%!-- Header --%>
          <div class="text-center mb-16">
            <h1 class="text-4xl sm:text-5xl font-extrabold tracking-tight text-base-content">
              <span class="text-primary">Services</span>
            </h1>
            <div class="mt-4 w-16 h-1 bg-primary mx-auto rounded-full"></div>
            <p class="mt-6 text-lg text-base-content/70 max-w-2xl mx-auto leading-relaxed">
              End-to-end consulting for BEAM-based systems — from architecture to production.
            </p>
          </div>

          <%!-- Service Cards --%>
          <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 mb-16">
            <.service_card
              icon="hero-code-bracket"
              title="Elixir / Phoenix Development"
              items={[
                "Phoenix LiveView applications",
                "Ash Framework integrations",
                "API design & development",
                "Real-time features & WebSockets"
              ]}
            />
            <.service_card
              icon="hero-cpu-chip"
              title="Erlang / OTP Systems"
              items={[
                "Distributed BEAM architecture",
                "Fault-tolerant OTP design",
                "Clustering & node management",
                "Hot code upgrades"
              ]}
            />
            <.service_card
              icon="hero-light-bulb"
              title="Architecture & Leadership"
              items={[
                "System design & review",
                "Technical leadership",
                "Team mentoring",
                "Code review & best practices"
              ]}
            />
            <.service_card
              icon="hero-shield-check"
              title="Infrastructure & Reliability"
              items={[
                "AWS infrastructure setup",
                "CI/CD pipeline design",
                "Monitoring & observability",
                "Incident response processes"
              ]}
            />
            <.service_card
              icon="hero-circle-stack"
              title="Data & Messaging Systems"
              items={[
                "PostgreSQL optimization",
                "Cassandra cluster management",
                "RabbitMQ architecture",
                "OpenSearch / Elasticsearch"
              ]}
            />
          </div>

          <%!-- Engagement Models --%>
          <div class="mb-16">
            <h2 class="text-2xl font-bold text-base-content text-center mb-8">Engagement Models</h2>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-6">
              <.engagement_card
                icon="hero-clock"
                title="Hourly Consulting"
                description="Flexible engagement for advisory, code review, architecture guidance, and short-term needs."
              />
              <.engagement_card
                icon="hero-document-check"
                title="Fixed-Scope Project"
                description="Well-defined projects with clear deliverables, timelines, and milestones from start to finish."
              />
              <.engagement_card
                icon="hero-calendar-days"
                title="Retainer / Advisory"
                description="Ongoing technical partnership with dedicated hours each month for continued support and guidance."
              />
            </div>
          </div>

          <%!-- CTA --%>
          <div class="text-center">
            <h2 class="text-2xl font-bold text-base-content mb-4">Ready to get started?</h2>
            <.link
              navigate={~p"/estimate"}
              class="btn btn-primary btn-lg gap-2 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-0.5"
            >
              <.icon name="hero-document-text" class="size-5" /> Request an Estimate
            </.link>
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end

  defp service_card(assigns) do
    ~H"""
    <div class="group rounded-2xl border border-base-300 bg-base-100 p-6 shadow-sm hover:shadow-md hover:border-primary/30 transition-all duration-300 hover:-translate-y-1">
      <div class="flex items-center gap-3 mb-4">
        <div class="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 text-primary group-hover:bg-primary/20 transition-colors">
          <.icon name={@icon} class="size-5" />
        </div>
        <h3 class="font-semibold text-base-content">{@title}</h3>
      </div>
      <ul class="space-y-2">
        <li :for={item <- @items} class="flex items-start gap-2 text-sm text-base-content/70">
          <.icon name="hero-check" class="size-4 text-primary shrink-0 mt-0.5" />
          <span>{item}</span>
        </li>
      </ul>
    </div>
    """
  end

  defp engagement_card(assigns) do
    ~H"""
    <div class="group rounded-2xl border border-base-300 bg-base-100 p-6 shadow-sm text-center hover:shadow-md hover:border-primary/30 transition-all duration-300">
      <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-primary/10 text-primary mx-auto mb-4 group-hover:bg-primary/20 transition-colors">
        <.icon name={@icon} class="size-6" />
      </div>
      <h3 class="font-semibold text-base-content mb-2">{@title}</h3>
      <p class="text-sm text-base-content/70 leading-relaxed">{@description}</p>
    </div>
    """
  end
end
