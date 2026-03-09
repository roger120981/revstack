defmodule RevstackWeb.ServicesLive do
  use RevstackWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       page_title: "Services — RevenueLink Technologies",
       current_path: "/services",
       beam_consulting_cards: beam_consulting_cards(),
       web_application_cards: web_application_cards(),
       local_technology_cards: local_technology_cards(),
       engagement_models: engagement_models(),
       typical_engagements: typical_engagements()
     )}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={assigns[:current_user]} current_path={@current_path}>
      <section class="pb-16 pt-6 sm:pb-24 sm:pt-10">
        <div class="mx-auto max-w-5xl">
          <div class="mx-auto mb-14 max-w-4xl text-center sm:mb-16">
            <div class="flex justify-center">
              <img
                id="services-page-logo"
                src="/images/revenuelink_main.png"
                alt="RevenueLink Technologies"
                class="h-auto w-full max-w-[230px] opacity-95 sm:max-w-[290px] lg:max-w-[340px]"
              />
            </div>
            <div class="mt-5 inline-flex items-center gap-2 rounded-full bg-primary/10 px-4 py-1.5 text-sm font-medium text-primary">
              <.icon name="hero-briefcase" class="size-4" /> Consulting & Delivery
            </div>
            <h1 class="mt-4 text-4xl font-extrabold tracking-tight text-base-content sm:text-5xl">
              <span class="text-primary">Services</span>
            </h1>
            <div class="mt-4 w-16 h-1 bg-primary mx-auto rounded-full"></div>
            <p class="mx-auto mt-6 max-w-3xl text-lg leading-relaxed text-base-content/70">
              RevenueLink Technologies supports high-trust consulting engagements, custom application delivery, and practical local technology work.
              The focus is reliable execution, clear communication, and production-ready results.
            </p>
          </div>

          <div id="services-overview" class="mb-16 sm:mb-20">
            <div class="grid grid-cols-1 gap-6 md:grid-cols-3">
              <.service_card
                id="services-overview-beam"
                icon="hero-cpu-chip"
                title="Distributed Systems & BEAM Consulting"
                items={[
                  "Architecture, reliability, and performance guidance for Erlang and Elixir systems",
                  "Production debugging, messaging, scaling, and observability support",
                  "Senior consulting for teams building or operating business-critical BEAM platforms"
                ]}
              />
              <.service_card
                id="services-overview-web"
                icon="hero-window"
                title="Custom Web Applications / Websites"
                items={[
                  "Custom Phoenix and LiveView applications, websites, and internal tools",
                  "Product-minded delivery for dashboards, APIs, and real-time experiences",
                  "Modern Elixir-based builds that are maintainable and production-ready"
                ]}
              />
              <.service_card
                id="services-overview-local"
                icon="hero-wrench-screwdriver"
                title="Local Technology Services"
                items={[
                  "Small business setups, workstation deployment, and network support",
                  "Custom gaming PCs and in-home troubleshooting for everyday technology issues",
                  "Friendly help fixing computers, setting up Wi-Fi and devices, configuring gaming PCs or VR systems, and recommending the right technology."
                ]}
              />
            </div>
          </div>

          <.service_path_section
            id="services-distributed-systems"
            title="Distributed Systems & BEAM Consulting"
            intro="Senior consulting for startups and engineering teams building on Erlang and Elixir. This work is aimed at architecture decisions, production hardening, operational clarity, and difficult systems problems that benefit from deep BEAM experience."
            cards={@beam_consulting_cards}
          />

          <.service_path_section
            id="services-custom-web-applications"
            title="Custom Web Applications"
            intro="I design and build modern production web applications, internal tools, and custom websites in Elixir and LiveView. Engagements focus on clear scope, strong architecture, and software that is practical to operate and evolve."
            cards={@web_application_cards}
          />

          <.service_path_section
            id="services-local-technology-services"
            title="Local Technology Services"
            intro="Helping local businesses and individuals deploy reliable technology solutions. The approach is professional, approachable, and centered on dependable setups that work in the real world."
            cards={@local_technology_cards}
          />

          <div id="engagement-models" class="mb-16 sm:mb-20">
            <h2 class="text-2xl font-bold text-base-content text-center mb-8">Engagement Models</h2>
            <p class="mx-auto mb-8 max-w-3xl text-center text-base text-base-content/70 leading-relaxed">
              Engagements can start small or grow into a deeper delivery partnership. Some clients need a senior technical sounding board, others need hands-on implementation with clear milestones and ownership.
            </p>
            <div class="grid grid-cols-1 sm:grid-cols-3 gap-6">
              <.engagement_card
                :for={engagement <- @engagement_models}
                icon={engagement.icon}
                title={engagement.title}
                description={engagement.description}
              />
            </div>
          </div>

          <div
            id="typical-engagements"
            class="mb-16 sm:mb-20 rounded-[2rem] border border-base-300 bg-base-200/50 px-6 py-10 shadow-sm sm:px-8"
          >
            <div class="text-center mb-8">
              <h2 class="text-3xl font-bold text-base-content">Typical Engagements</h2>
              <div class="mt-3 w-16 h-1 bg-primary mx-auto rounded-full"></div>
              <p class="mt-5 max-w-3xl mx-auto text-base text-base-content/70 leading-relaxed">
                A few representative ways teams and local clients typically bring me in when they need focused execution, technical clarity, or a concrete delivery plan.
              </p>
              <p class="mt-4 max-w-2xl mx-auto text-sm text-base-content/55 leading-relaxed">
                These examples are meant to make scoping easier. If your project overlaps multiple categories, I can help define the right engagement shape and next step.
              </p>
            </div>

            <div class="grid grid-cols-1 gap-6 md:grid-cols-2 xl:grid-cols-3">
              <.engagement_example_card
                :for={engagement <- @typical_engagements}
                id={engagement.id}
                icon={engagement.icon}
                title={engagement.title}
                items={engagement.items}
              />
            </div>
          </div>

          <div class="rounded-[2rem] border border-base-300 bg-base-100 px-6 py-10 text-center shadow-sm sm:px-8">
            <h2 class="text-2xl font-bold text-base-content mb-4">Ready to start a conversation?</h2>
            <p class="mx-auto max-w-2xl text-base text-base-content/70 leading-relaxed">
              If you already have a project in mind, request an estimate and I’ll respond with next steps. If you’re evaluating me for a full-time backend or distributed systems role, my profile remains the best starting point.
            </p>
            <div class="mt-8 flex flex-col items-center justify-center gap-3 sm:flex-row">
              <.link
                id="request-estimate-cta"
                navigate={~p"/estimate"}
                class="btn btn-primary btn-lg gap-2 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-0.5"
              >
                <.icon name="hero-document-text" class="size-5" /> Request an Estimate
              </.link>
              <.link
                id="services-profile-cta"
                navigate={~p"/whoami"}
                class="btn btn-outline btn-lg gap-2"
              >
                <.icon name="hero-user-circle" class="size-5" /> View Profile
              </.link>
            </div>
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end

  attr :id, :string, required: true
  attr :title, :string, required: true
  attr :intro, :string, required: true
  attr :cards, :list, required: true

  defp service_path_section(assigns) do
    ~H"""
    <section id={@id} class="mb-16 sm:mb-20">
      <div class="mb-8 sm:mb-10">
        <h2 class="text-3xl font-bold text-base-content">{@title}</h2>
        <div class="mt-3 h-1 w-16 rounded-full bg-primary"></div>
        <p class="mt-5 max-w-3xl text-base text-base-content/70 leading-relaxed">
          {@intro}
        </p>
      </div>

      <div class="grid grid-cols-1 gap-6 md:grid-cols-2 xl:grid-cols-3">
        <.service_card
          :for={card <- @cards}
          id={card.id}
          icon={card.icon}
          title={card.title}
          items={card.items}
        />
      </div>
    </section>
    """
  end

  attr :id, :string, required: true
  attr :icon, :string, required: true
  attr :title, :string, required: true
  attr :items, :list, required: true

  defp service_card(assigns) do
    ~H"""
    <div
      id={@id}
      class="group rounded-2xl border border-base-300 bg-base-100 p-6 shadow-sm hover:border-primary/30 hover:shadow-md transition-all duration-300 hover:-translate-y-1"
    >
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

  attr :id, :string, required: true
  attr :icon, :string, required: true
  attr :title, :string, required: true
  attr :items, :list, required: true

  defp engagement_example_card(assigns) do
    ~H"""
    <div id={@id} class="rounded-2xl border border-base-300 bg-base-100 p-6 shadow-sm">
      <div class="flex items-center gap-3 mb-4">
        <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary">
          <.icon name={@icon} class="size-5" />
        </div>
        <div>
          <p class="text-xs font-semibold uppercase tracking-[0.16em] text-primary/80">
            Example engagement
          </p>
          <h3 class="text-lg font-semibold text-base-content">{@title}</h3>
        </div>
      </div>

      <ul class="space-y-2">
        <li :for={item <- @items} class="flex items-start gap-2 text-sm text-base-content/70">
          <.icon name="hero-check-badge" class="mt-0.5 size-4 shrink-0 text-primary" />
          <span>{item}</span>
        </li>
      </ul>
    </div>
    """
  end

  defp beam_consulting_cards do
    [
      %{
        id: "service-beam-architecture",
        icon: "hero-cpu-chip",
        title: "Erlang / OTP Architecture Consulting",
        items: [
          "OTP design reviews and supervision strategy",
          "Distributed node topology and clustering decisions",
          "System boundaries, failure modes, and operational tradeoffs",
          "Architecture guidance for long-lived BEAM platforms"
        ]
      },
      %{
        id: "service-elixir-phoenix",
        icon: "hero-code-bracket",
        title: "Elixir / Phoenix Application Development",
        items: [
          "Phoenix and LiveView application delivery",
          "Backend features, APIs, and business workflows",
          "Production-ready application structure and conventions",
          "Hands-on implementation for critical roadmap work"
        ]
      },
      %{
        id: "service-distributed-systems",
        icon: "hero-globe-alt",
        title: "Distributed Systems Design",
        items: [
          "High-throughput event and message processing systems",
          "Queueing, delivery guarantees, and fault tolerance",
          "Real-time coordination and multi-node design",
          "Scalable architecture for business-critical workloads"
        ]
      },
      %{
        id: "service-performance-reliability",
        icon: "hero-shield-check",
        title: "Performance Optimization & Reliability",
        items: [
          "Performance tuning across application, VM, and database layers",
          "Reliability engineering and operational hardening",
          "Release strategy, deployment confidence, and risk reduction",
          "Observability and infrastructure improvements"
        ]
      },
      %{
        id: "service-production-debugging",
        icon: "hero-bug-ant",
        title: "Production Debugging for BEAM Systems",
        items: [
          "Investigating latency, throughput, and crash behavior",
          "Root-cause analysis for hard-to-reproduce production issues",
          "Stabilization plans for degraded or fragile systems",
          "Pragmatic remediation with clear next-step recommendations"
        ]
      },
      %{
        id: "service-data-messaging",
        icon: "hero-circle-stack",
        title: "Messaging, Data & Observability",
        items: [
          "RabbitMQ and Kafka-adjacent eventing patterns",
          "Postgres optimization and Cassandra scaling guidance",
          "Metrics, logging, tracing, and operational visibility",
          "Infrastructure recommendations that support sustained growth"
        ]
      }
    ]
  end

  defp web_application_cards do
    [
      %{
        id: "service-liveview-apps",
        icon: "hero-window",
        title: "Phoenix / LiveView Applications & Websites",
        items: [
          "Interactive product experiences with LiveView",
          "Custom websites and product-facing experiences built in Elixir",
          "Admin surfaces, workflow tooling, and secure data handling",
          "Modern Elixir-first delivery without unnecessary complexity",
          "Production deployment and maintainable code structure"
        ]
      },
      %{
        id: "service-internal-tools",
        icon: "hero-wrench-screwdriver",
        title: "Internal Business Tools",
        items: [
          "Custom internal platforms tailored to team workflows",
          "Operational tooling that replaces brittle spreadsheets or manual steps",
          "Approval flows, reporting, and back-office functionality",
          "Practical software aligned to how the business actually operates"
        ]
      },
      %{
        id: "service-dashboards-analytics",
        icon: "hero-chart-bar-square",
        title: "Dashboards & Analytics Systems",
        items: [
          "Executive and operational visibility dashboards",
          "Analytics interfaces for teams that need live data",
          "Metrics presentation designed for clarity and decision-making",
          "Backend data flows that support trustworthy reporting"
        ]
      },
      %{
        id: "service-real-time-apps",
        icon: "hero-bolt",
        title: "Real-Time Applications",
        items: [
          "Live collaboration, activity feeds, and event-driven interfaces",
          "Low-latency updates backed by stable server-side architecture",
          "Real-time experiences that remain operable in production",
          "Delivery plans that balance ambition with implementation reality"
        ]
      },
      %{
        id: "service-apis-backends",
        icon: "hero-server-stack",
        title: "APIs & Backend Services",
        items: [
          "HTTP APIs and backend services for products and integrations",
          "Domain modeling, workflow orchestration, and service boundaries",
          "Reliable background processing and external system integrations",
          "Backend design that supports growth without constant rewrites"
        ]
      }
    ]
  end

  defp local_technology_cards do
    [
      %{
        id: "service-gaming-pc-builds",
        icon: "hero-computer-desktop",
        title: "Custom Gaming PC Builds",
        items: [
          "Part selection guidance based on budget and goals",
          "Full system assembly and setup",
          "Performance-minded recommendations without upsell pressure",
          "A clean, reliable build tailored to how you actually use it"
        ]
      },
      %{
        id: "service-network-setup",
        icon: "hero-wifi",
        title: "Small Business Network Setup",
        items: [
          "Network planning for small offices and shared spaces",
          "Router, switch, and connectivity recommendations",
          "Reliable Wi-Fi and workstation connectivity",
          "Clear, practical setups that are easy to support afterward"
        ]
      },
      %{
        id: "service-office-setup",
        icon: "hero-building-office-2",
        title: "Workstation & Office Setup",
        items: [
          "Desktop and workstation installation",
          "Peripheral, monitor, and workspace setup",
          "Software baseline configuration for day-to-day work",
          "Straightforward deployment for productive teams"
        ]
      },
      %{
        id: "service-small-business-tech-consulting",
        icon: "hero-light-bulb",
        title: "Technology Consulting for Small Businesses",
        items: [
          "Hardware and software planning",
          "Practical recommendations for upgrades or new setups",
          "Technology decisions explained in business-friendly language",
          "Trusted guidance for owners who want to avoid bad purchases"
        ]
      },
      %{
        id: "service-home-tech-support",
        icon: "hero-wrench",
        title: "In-Home Technology Troubleshooting",
        items: [
          "Diagnosing and fixing home computer issues",
          "Printer setup and troubleshooting",
          "Home network and Wi-Fi problems",
          "Software installation and system cleanup",
          "Friendly, practical help for non-technical users"
        ]
      }
    ]
  end

  defp engagement_models do
    [
      %{
        icon: "hero-clock",
        title: "Hourly Consulting",
        description:
          "Flexible support for architecture guidance, code review, production debugging, implementation help, and short targeted engagements."
      },
      %{
        icon: "hero-document-check",
        title: "Fixed-Scope Project",
        description:
          "Well-defined delivery with agreed scope, milestones, and concrete outcomes for custom applications, websites, internal tools, or infrastructure improvements."
      },
      %{
        icon: "hero-calendar-days",
        title: "Retainer / Advisory",
        description:
          "Ongoing partnership for teams that need senior engineering judgment, delivery continuity, and a reliable technical counterpart over time."
      }
    ]
  end

  defp typical_engagements do
    [
      %{
        id: "engagement-beam-system-review",
        icon: "hero-cpu-chip",
        title: "BEAM System Review",
        items: [
          "Architecture review",
          "Reliability risk assessment",
          "Scaling bottleneck analysis",
          "Performance tuning recommendations"
        ]
      },
      %{
        id: "engagement-new-liveview-app",
        icon: "hero-window",
        title: "New Phoenix / LiveView Application",
        items: [
          "Build a custom internal tool or customer-facing app",
          "Define scope, architecture, and delivery plan",
          "Structure the system for maintainable growth",
          "Ship with a production-ready foundation"
        ]
      },
      %{
        id: "engagement-custom-website",
        icon: "hero-globe-alt",
        title: "Custom Website or Product Site",
        items: [
          "Build a custom website in Elixir and LiveView",
          "Align messaging, user flow, and business goals",
          "Keep the stack maintainable and production-ready",
          "Launch with room to evolve into richer product features"
        ]
      },
      %{
        id: "engagement-production-debugging",
        icon: "hero-bug-ant",
        title: "Production Debugging & Stabilization",
        items: [
          "Investigate performance issues",
          "Reduce operational risk",
          "Improve reliability and observability",
          "Turn a fragile system into an operable one"
        ]
      },
      %{
        id: "engagement-local-business-setup",
        icon: "hero-building-office-2",
        title: "Local Business Technology Setup",
        items: [
          "Office workstation setup",
          "Network planning",
          "Hardware and software recommendations",
          "Deployment guidance for dependable day-to-day operations"
        ]
      },
      %{
        id: "engagement-gaming-pc-build",
        icon: "hero-computer-desktop",
        title: "Custom Gaming PC Build",
        items: [
          "Part selection guidance",
          "Full build and setup",
          "Tailored to budget and goals",
          "Delivered with practical recommendations and a clean finish"
        ]
      }
    ]
  end
end
