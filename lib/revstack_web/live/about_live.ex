defmodule RevstackWeb.AboutLive do
  use RevstackWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "About — RevenueLink Technologies")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={assigns[:current_user]}>
      <section class="py-16 sm:py-24">
        <div class="mx-auto max-w-4xl">
          <%!-- Header --%>
          <div class="text-center mb-16">
            <h1 class="text-4xl sm:text-5xl font-extrabold tracking-tight text-base-content">
              About <span class="text-primary">RevenueLink</span>
            </h1>
            <div class="mt-4 w-16 h-1 bg-primary mx-auto rounded-full"></div>
            <p class="mt-6 text-lg text-base-content/70 max-w-2xl mx-auto leading-relaxed">
              RevenueLink Technologies LLC — Consulting and engineering services for the BEAM ecosystem.
            </p>
          </div>

          <%!-- Founder Section --%>
          <div class="rounded-2xl border border-base-300 bg-base-100 p-8 sm:p-10 shadow-sm mb-12">
            <div class="flex flex-col sm:flex-row items-start gap-6">
              <div class="flex h-16 w-16 shrink-0 items-center justify-center rounded-2xl bg-primary/10 text-primary">
                <.icon name="hero-user" class="size-8" />
              </div>
              <div>
                <h2 class="text-2xl font-bold text-base-content mb-1">Kyle Neal</h2>
                <p class="text-primary font-medium mb-4">Founder &amp; Lead Engineer</p>
                <div class="space-y-3 text-base-content/80 leading-relaxed">
                  <p>
                    Lead Elixir/Erlang Engineer and Technical Leader with deep expertise in
                    distributed systems architecture, BEAM-based application development, and
                    production infrastructure engineering.
                  </p>
                  <p>
                    I own the full architecture lifecycle — from system design through deployment and
                    operational excellence. With experience spanning both backend and fullstack
                    development, I bring a production-focused mindset to every engagement.
                  </p>
                </div>
              </div>
            </div>
          </div>

          <%!-- Tech Stack --%>
          <div class="mb-12">
            <h2 class="text-2xl font-bold text-base-content text-center mb-8">Technical Expertise</h2>
            <div class="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-5 gap-4">
              <.tech_badge label="Elixir" />
              <.tech_badge label="Erlang/OTP" />
              <.tech_badge label="Phoenix LiveView" />
              <.tech_badge label="Ash Framework" />
              <.tech_badge label="PostgreSQL" />
              <.tech_badge label="Cassandra" />
              <.tech_badge label="RabbitMQ" />
              <.tech_badge label="AWS" />
              <.tech_badge label="CI/CD" />
              <.tech_badge label="Linux" />
            </div>
          </div>

          <%!-- CTA --%>
          <div class="text-center">
            <.link
              navigate={~p"/services"}
              class="btn btn-primary btn-lg gap-2 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-0.5"
            >
              <.icon name="hero-briefcase" class="size-5" /> View Services
            </.link>
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end

  defp tech_badge(assigns) do
    ~H"""
    <div class="flex items-center justify-center rounded-xl border border-base-300 bg-base-100 px-4 py-3 text-sm font-medium text-base-content shadow-sm hover:border-primary/30 hover:shadow-md transition-all duration-200">
      {@label}
    </div>
    """
  end
end
