defmodule RevstackWeb.HomeLive do
  use RevstackWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "RevenueLink Technologies | Elixir & Erlang Consulting",
       current_path: "/"
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={assigns[:current_user]} current_path={@current_path}>
      <%!-- Hero Section --%>
      <section class="relative overflow-hidden py-20 sm:py-32">
        <div class="mx-auto max-w-4xl text-center">
          <h1 class="text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tight text-base-content leading-tight">
            RevenueLink Technologies: Elixir &amp; Erlang consulting for
            <span class="text-primary">reliable, high-scale systems.</span>
          </h1>
          <p class="mt-6 text-lg sm:text-xl text-base-content/70 max-w-2xl mx-auto leading-relaxed">
            I build distributed BEAM systems, Phoenix LiveView applications, and production-ready
            infrastructure focused on correctness and uptime.
          </p>
          <div class="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
            <.link
              navigate={~p"/estimate"}
              class="btn btn-primary btn-lg gap-2 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-0.5"
            >
              <.icon name="hero-document-text" class="size-5" /> Request an Estimate
            </.link>
            <.link
              navigate={~p"/contact"}
              class="btn btn-outline btn-lg gap-2 transition-all duration-300 hover:-translate-y-0.5"
            >
              <.icon name="hero-chat-bubble-left-right" class="size-5" /> Contact
            </.link>
          </div>
        </div>
      </section>

      <%!-- What I Do Section --%>
      <section class="py-16 sm:py-24">
        <div class="mx-auto max-w-5xl">
          <div class="text-center mb-12">
            <h2 class="text-3xl sm:text-4xl font-bold text-base-content">What I Do</h2>
            <div class="mt-3 w-16 h-1 bg-primary mx-auto rounded-full"></div>
          </div>
          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
            <.tech_card
              icon="hero-code-bracket"
              title="Elixir / Phoenix / Ash"
              description="Full-stack Phoenix LiveView applications with Ash Framework for rapid, maintainable development."
            />
            <.tech_card
              icon="hero-cpu-chip"
              title="Erlang / OTP"
              description="Distributed systems built on the BEAM with fault tolerance, concurrency, and high availability."
            />
            <.tech_card
              icon="hero-circle-stack"
              title="Data Systems"
              description="PostgreSQL, Cassandra, OpenSearch — schema design, query optimization, and data pipelines."
            />
            <.tech_card
              icon="hero-arrow-path"
              title="RabbitMQ"
              description="Message-driven architectures with reliable pub/sub, work queues, and event streaming."
            />
            <.tech_card
              icon="hero-cloud"
              title="AWS / Infrastructure"
              description="Production cloud infrastructure, Linux administration, CI/CD pipelines, and Ansible automation."
            />
            <.tech_card
              icon="hero-eye"
              title="Observability"
              description="Monitoring, logging, tracing, and alerting for production systems that need to stay up."
            />
          </div>
        </div>
      </section>

      <%!-- How I Help Section --%>
      <section class="py-16 sm:py-24 bg-base-200/50 -mx-4 sm:-mx-6 lg:-mx-8 px-4 sm:px-6 lg:px-8 rounded-2xl">
        <div class="mx-auto max-w-5xl">
          <div class="text-center mb-12">
            <h2 class="text-3xl sm:text-4xl font-bold text-base-content">How I Help</h2>
            <div class="mt-3 w-16 h-1 bg-primary mx-auto rounded-full"></div>
          </div>
          <div class="grid grid-cols-1 md:grid-cols-2 gap-8">
            <.help_card
              icon="hero-rocket-launch"
              title="Build New BEAM Systems"
              description="From greenfield to production, architecture, implementation, and deployment of Elixir/Erlang applications."
            />
            <.help_card
              icon="hero-wrench-screwdriver"
              title="Modernize Legacy Systems"
              description="Migrate, refactor, and upgrade existing systems to modern BEAM architectures with zero downtime."
            />
            <.help_card
              icon="hero-shield-check"
              title="Improve Reliability & Observability"
              description="Add monitoring, alerting, error tracking, and resilience patterns to keep your systems running."
            />
            <.help_card
              icon="hero-light-bulb"
              title="Technical Leadership & Architecture"
              description="System design, code reviews, team mentoring, and strategic technical direction for your engineering org."
            />
          </div>
        </div>
      </section>

      <%!-- CTA Section --%>
      <section class="py-20 sm:py-28">
        <div class="mx-auto max-w-2xl text-center">
          <h2 class="text-3xl sm:text-4xl font-bold text-base-content">
            Let's build something <span class="text-primary">reliable.</span>
          </h2>
          <p class="mt-4 text-lg text-base-content/70">
            Ready to start your next project? Let's talk about what you need.
          </p>
          <div class="mt-8">
            <.link
              navigate={~p"/estimate"}
              class="btn btn-primary btn-lg gap-2 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-0.5"
            >
              <.icon name="hero-document-text" class="size-5" /> Get an Estimate
            </.link>
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end

  defp tech_card(assigns) do
    ~H"""
    <div class="group rounded-2xl border border-base-300 bg-base-100 p-6 shadow-sm hover:shadow-md hover:border-primary/30 transition-all duration-300 hover:-translate-y-1">
      <div class="flex items-center gap-3 mb-3">
        <div class="flex h-10 w-10 items-center justify-center rounded-lg bg-primary/10 text-primary group-hover:bg-primary/20 transition-colors">
          <.icon name={@icon} class="size-5" />
        </div>
        <h3 class="font-semibold text-base-content">{@title}</h3>
      </div>
      <p class="text-sm text-base-content/70 leading-relaxed">{@description}</p>
    </div>
    """
  end

  defp help_card(assigns) do
    ~H"""
    <div class="group flex gap-4 rounded-2xl border border-base-300 bg-base-100 p-6 shadow-sm hover:shadow-md hover:border-primary/30 transition-all duration-300">
      <div class="flex h-12 w-12 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary group-hover:bg-primary/20 transition-colors">
        <.icon name={@icon} class="size-6" />
      </div>
      <div>
        <h3 class="font-semibold text-base-content mb-1">{@title}</h3>
        <p class="text-sm text-base-content/70 leading-relaxed">{@description}</p>
      </div>
    </div>
    """
  end
end
