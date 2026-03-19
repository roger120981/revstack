defmodule RevstackWeb.WhoamiLive do
  use RevstackWeb, :live_view

  @admin_gallery_images [
    %{
      src: "/images/admin_panel/admin_dashboard.png",
      title: "Admin Dashboard",
      description:
        "The main dashboard with quick-access summary cards and sidebar navigation for the admin panel."
    },
    %{
      src: "/images/admin_panel/lead_listing.png",
      title: "Lead Listing",
      description:
        "Real-time data grid of all leads with status badges, filtering, and pagination."
    },
    %{
      src: "/images/admin_panel/lead_view.png",
      title: "Lead Detail View",
      description:
        "Detailed view of a single lead with all associated data, status history, and action buttons."
    },
    %{
      src: "/images/admin_panel/estimate_listing.png",
      title: "Estimate Listing",
      description:
        "Data grid of all estimates with filtering by status, date, and associated lead."
    },
    %{
      src: "/images/admin_panel/estimate_view.png",
      title: "Estimate Detail View",
      description:
        "Detailed view of a single estimate with line items, total calculation, and status management."
    },
    %{
      src: "/images/admin_panel/visitors_listing.png",
      title: "Visitor Tracking",
      description:
        "Real-time listing of website visitors with IP, user agent, and page visit (count) for lead qualification."
    },
    %{
      src: "/images/admin_panel/visitors_view.png",
      title: "Visitor Detail View",
      description:
        "Detailed view of a single visitor with timeline of interactions, submitted forms, and lead conversion status."
    }
  ]

  @section_navigation_items [
    %{id: "whoami-hero", label: "Hero"},
    %{id: "whoami-glance", label: "At A Glance"},
    %{id: "whoami-summary", label: "Professional Summary"},
    %{id: "whoami-expertise", label: "Technical Expertise"},
    %{id: "whoami-experience", label: "Professional Experience"},
    %{id: "whoami-portfolio", label: "Career Portfolio"},
    %{id: "live-projects", label: "Personal Live Projects"},
    %{id: "leadership-teamwork", label: "Leadership & Teamwork"},
    %{id: "whoami-education", label: "Education"},
    %{id: "whoami-interests", label: "When I'm Not Coding"},
    %{id: "whoami-contact", label: "Contact"},
    %{id: "whoami-source", label: "Source Code"}
  ]

  @impl true
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        page_title: "Kyle Neal | Lead Distributed Systems Engineer",
        page_description:
          "Kyle Neal — Lead Distributed Systems Engineer specializing in Erlang/OTP, Elixir, high-throughput event systems, distributed data platforms, and hands-on technical leadership.",
        current_path: "/whoami",
        admin_gallery_open?: false,
        admin_gallery_index: 0,
        admin_gallery_images: @admin_gallery_images,
        section_nav_open?: false,
        section_navigation_items: @section_navigation_items,
        career_modal_open?: false,
        career_selected_project_id: nil,
        career_detail_view?: false,
        career_expanded_phase_id: nil,
        career_phases: [career_portfolio_phase_two(), career_portfolio_phase_one()]
      )

    {:ok, socket}
  end

  @impl true
  def handle_event("open_admin_gallery", _params, socket) do
    {:noreply, assign(socket, admin_gallery_open?: true, admin_gallery_index: 0)}
  end

  def handle_event("close_admin_gallery", _params, socket) do
    {:noreply, assign(socket, admin_gallery_open?: false)}
  end

  def handle_event("admin_gallery_prev", _params, socket) do
    index = max(socket.assigns.admin_gallery_index - 1, 0)
    {:noreply, assign(socket, :admin_gallery_index, index)}
  end

  def handle_event("admin_gallery_next", _params, socket) do
    max_index = length(@admin_gallery_images) - 1
    index = min(socket.assigns.admin_gallery_index + 1, max_index)
    {:noreply, assign(socket, :admin_gallery_index, index)}
  end

  def handle_event("admin_gallery_select", %{"index" => index}, socket) do
    {:noreply, assign(socket, :admin_gallery_index, String.to_integer(index))}
  end

  def handle_event("toggle_section_nav", _params, socket) do
    {:noreply, assign(socket, :section_nav_open?, !socket.assigns.section_nav_open?)}
  end

  def handle_event("close_section_nav", _params, socket) do
    {:noreply, assign(socket, :section_nav_open?, false)}
  end

  def handle_event("expand_career_phase", %{"phase-id" => phase_id}, socket) do
    {:noreply, assign(socket, career_expanded_phase_id: phase_id)}
  end

  def handle_event("collapse_career_phase", _params, socket) do
    {:noreply, assign(socket, career_expanded_phase_id: nil)}
  end

  def handle_event("open_career_modal", %{"project-id" => project_id}, socket) do
    {:noreply,
     assign(socket,
       career_modal_open?: true,
       career_selected_project_id: project_id,
       career_detail_view?: false
     )}
  end

  def handle_event("close_career_modal", _params, socket) do
    {:noreply,
     assign(socket,
       career_modal_open?: false,
       career_selected_project_id: nil,
       career_detail_view?: false
     )}
  end

  def handle_event("select_career_project", %{"project-id" => project_id}, socket) do
    {:noreply,
     assign(socket,
       career_selected_project_id: project_id,
       career_detail_view?: false
     )}
  end

  def handle_event("view_career_detail", _params, socket) do
    {:noreply, assign(socket, career_detail_view?: true)}
  end

  def handle_event("back_career_overview", _params, socket) do
    {:noreply, assign(socket, career_detail_view?: false)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={assigns[:current_user]} current_path={@current_path}>
      <:header_left>
        <.section_navigation_toggle menu_open?={@section_nav_open?} />
      </:header_left>
      <.section_navigation_panel
        :if={@section_nav_open?}
        items={@section_navigation_items}
      />
      <div id="whoami-sections" class="space-y-6 sm:space-y-8 lg:space-y-10">
        <.hero_section />
        <.at_a_glance_section />
        <.professional_summary_section />
        <.technical_expertise_section />
        <.professional_experience_section />
        <.career_portfolio_section
          career_phases={@career_phases}
          expanded_phase_id={@career_expanded_phase_id}
        />
        <.live_projects_section admin_gallery_images={@admin_gallery_images} />
        <.leadership_and_teamwork_section />
        <.education_section />
        <.personal_interests_section />
        <.closing_cta_section />
        <.github_repository_section />
      </div>
      <.career_portfolio_modal
        :if={@career_modal_open?}
        phases={@career_phases}
        selected_project_id={@career_selected_project_id}
        detail_view?={@career_detail_view?}
      />
      <.admin_gallery_modal
        :if={@admin_gallery_open?}
        images={@admin_gallery_images}
        current_index={@admin_gallery_index}
      />
    </Layouts.app>
    """
  end

  # ---------------------------------------------------------------------------
  # Page Sections
  # ---------------------------------------------------------------------------

  defp hero_section(assigns) do
    ~H"""
    <section id="whoami-hero" class="py-20 sm:py-28 scroll-mt-24">
      <div class="mx-auto max-w-4xl text-center">
        <div class="inline-flex items-center gap-2 rounded-full bg-primary/10 px-4 py-1.5 text-sm font-medium text-primary mb-6">
          <.icon name="hero-cpu-chip" class="size-4" /> Distributed Systems Engineer
        </div>
        <h1 class="text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tight text-base-content leading-tight">
          Kyle Neal
        </h1>
        <p id="whoami-role-title" class="mt-2 text-xl sm:text-2xl text-primary font-semibold">
          Lead Distributed Systems Engineer
        </p>
        <p
          id="whoami-skill-signature"
          class="mt-6 text-lg text-base-content/70 max-w-2xl mx-auto leading-relaxed"
        >
          Erlang/OTP and Elixir engineer building revenue-critical systems on the BEAM.
          I&apos;ve owned affiliate tracking, attribution, reporting, and infrastructure platforms
          supporting 1.5M+ events/day, $2.5M+ monthly revenue, and hands-on leadership of up to 5 engineers.
        </p>
        <div class="mt-8 flex flex-col items-center gap-3">
          <div class="flex items-center gap-2">
            <a
              id="view-resume-link"
              href="/resume/kyle-neal-resume.pdf"
              target="_blank"
              rel="noopener noreferrer"
              class="btn btn-outline btn-md sm:btn-lg gap-2 shadow-sm hover:shadow-md transition-all duration-300 hover:-translate-y-0.5"
            >
              <.icon name="hero-eye" class="size-5" /> View Resume
            </a>
            <a
              id="download-resume-link"
              href="/resume/download/kyle-neal-resume.pdf"
              download
              title="Download Kyle's Resume"
              aria-label="Download Kyle's Resume"
              class="btn btn-outline btn-md sm:btn-lg gap-2 shadow-sm hover:shadow-md transition-all duration-300 hover:-translate-y-0.5"
            >
              <.icon name="hero-arrow-down-tray" class="size-5" />
            </a>
          </div>
          <.link
            navigate={~p"/contact"}
            id="hero-contact-link"
            class="btn btn-primary btn-md sm:btn-lg gap-2 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-0.5 w-full sm:w-auto max-w-xs"
          >
            <.icon name="hero-envelope" class="size-5" /> Contact Me
          </.link>
        </div>
        <%!-- Quick links --%>
        <div class="mt-6 flex flex-col items-center gap-3 text-sm text-base-content/50">
          <div class="flex flex-wrap items-center justify-center gap-x-5 gap-y-2">
            <a
              id="whoami-github-link"
              href="https://github.com/kyle-neal"
              target="_blank"
              rel="noopener noreferrer"
              class="inline-flex items-center gap-1.5 hover:text-base-content transition-colors"
            >
              <svg viewBox="0 0 16 16" class="size-4 fill-current" aria-hidden="true">
                <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z" />
              </svg>
              GitHub
            </a>
            <a
              id="personal-email-link"
              href="mailto:nealkyle5@gmail.com"
              class="inline-flex items-center gap-1.5 hover:text-base-content transition-colors"
            >
              <.icon name="hero-envelope" class="size-4" /> nealkyle5@gmail.com
            </a>
          </div>
        </div>
      </div>
    </section>
    """
  end

  defp at_a_glance_section(assigns) do
    ~H"""
    <section id="whoami-glance" class="py-12 scroll-mt-24">
      <div class="mx-auto max-w-5xl">
        <div class="grid grid-cols-2 lg:grid-cols-3 gap-4">
          <.stat_card
            value="10+"
            headline="Years building on the BEAM"
            detail="Erlang/OTP + Elixir in production"
          />
          <.stat_card
            value="1.5M+"
            headline="Events processed per day"
            detail="tracking, attribution, and reporting workloads"
          />
          <.stat_card
            value="$2.5M+"
            headline="Monthly revenue supported"
            detail="revenue-critical platform ownership"
          />
          <.stat_card
            value="6-node"
            headline="Cassandra event store"
            detail="operated in production for high-volume tracking data"
          />
          <.stat_card
            value="~25%"
            headline="Infrastructure cost reduction"
            detail="delivered through audits and scaling changes"
          />
          <.stat_card
            value="5"
            headline="Engineers led hands-on"
            detail="across UI and infrastructure"
          />
        </div>
      </div>
    </section>
    """
  end

  defp professional_summary_section(assigns) do
    ~H"""
    <section id="whoami-summary" class="section-card py-16 sm:py-20 px-4 sm:px-6 lg:px-8 scroll-mt-24">
      <div class="mx-auto max-w-4xl">
        <div class="text-center mb-12">
          <h2 class="text-3xl font-bold text-base-content">Professional Summary</h2>
          <div class="mt-3 w-16 h-1 bg-primary mx-auto rounded-full"></div>
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
          <.summary_item
            icon="hero-cpu-chip"
            text="Lead distributed systems engineer specializing in long-lived production systems built with Erlang/OTP and Elixir"
          />
          <.summary_item
            icon="hero-server-stack"
            text="Built and operated a revenue-critical affiliate platform handling high-volume click tracking, attribution, callbacks, analytics, and partner reporting"
          />
          <.summary_item
            icon="hero-cog-6-tooth"
            text="Architected NetAdmin, an Elixir/Phoenix LiveView + Ash control plane for lifecycle orchestration, monitoring, auditability, and automation"
          />
          <.summary_item
            icon="hero-circle-stack"
            text="Designs distributed data and messaging systems across Cassandra, PostgreSQL, RabbitMQ, Elasticsearch/OpenSearch, and Spark pipelines"
          />
          <.summary_item
            icon="hero-globe-alt"
            text="Comfortable close to the wire with HTTP, WebSockets, DNS, SMTP, and proxying in production systems"
          />
          <.summary_item
            icon="hero-bolt"
            text="Reliability-focused owner of OTP supervision, BEAM tuning, relup upgrades, CI/CD, and production incident debugging"
          />
          <.summary_item
            icon="hero-user-group"
            text="Hands-on technical lead who hired, mentored, and managed up to 5 engineers without stepping away from architecture or code"
          />
          <.summary_item
            icon="hero-cloud"
            text="Infrastructure-aware across AWS, Linux, VPS fleets, Jenkins, and Ansible, with a practical cost and operability mindset"
          />
        </div>
      </div>
    </section>
    """
  end

  defp technical_expertise_section(assigns) do
    ~H"""
    <section
      id="whoami-expertise"
      class="section-card py-16 sm:py-20 bg-base-200/30 px-4 sm:px-6 lg:px-8 scroll-mt-24"
    >
      <div class="mx-auto max-w-5xl">
        <div class="text-center mb-12">
          <h2 class="text-3xl font-bold text-base-content">Technical Expertise</h2>
          <div class="mt-3 w-16 h-1 bg-primary mx-auto rounded-full"></div>
        </div>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <.expertise_group
            title="BEAM & Languages"
            items={[
              "Erlang/OTP for high-throughput, fault-tolerant services",
              "Elixir application and platform development",
              "Phoenix + LiveView",
              "Ash Framework",
              "BEAM VM tuning and relup zero-downtime upgrades",
              "REST API design and third-party integrations"
            ]}
          />
          <.expertise_group
            title="Data & Messaging"
            items={[
              "Cassandra (6-node production cluster, time-series modeling)",
              "PostgreSQL query tuning and reporting workloads",
              "RabbitMQ distributed messaging pipelines",
              "Elasticsearch / OpenSearch analytics",
              "Apache Spark (Scala, AWS EMR)",
              "Event ingestion and reporting pipelines at 1.5M+ events/day"
            ]}
          />
          <.expertise_group
            title="Infrastructure & Protocols"
            items={[
              "AWS (EC2, RDS, S3)",
              "Linux operations & administration",
              "Ansible automation",
              "CI/CD with Jenkins",
              "HTTP, WebSockets, DNS, SMTP, and proxies",
              "Observability, monitoring, and reliability engineering"
            ]}
          />
        </div>
      </div>
    </section>
    """
  end

  defp professional_experience_section(assigns) do
    ~H"""
    <section
      id="whoami-experience"
      class="section-card py-16 sm:py-20 px-4 sm:px-6 lg:px-8 scroll-mt-24"
    >
      <div class="mx-auto max-w-4xl">
        <div class="text-center mb-12">
          <h2 class="text-3xl font-bold text-base-content">Professional Experience</h2>
          <div class="mt-3 w-16 h-1 bg-primary mx-auto rounded-full"></div>
        </div>
        <div class="space-y-8">
          <.experience_card
            id="experience-ionik"
            title="Lead Distributed Systems Engineer"
            company="Ionik (formerly VeriAS)"
            period="October 2014 — Present"
            current?={true}
            items={[
              "Lead architect and primary backend engineer for a revenue-critical affiliate marketing platform using Erlang/OTP. The platform supports $2.5M+ monthly revenue, processes 1.5M+ events daily, and powers high-volume click tracking, attribution, and real-time partner reporting.",
              "Owned backend platform design across tracking, analytics, and partner connectivity, including REST APIs and internal service integrations used throughout the product.",
              "Designed and operated distributed data and messaging architecture including a 6-node Cassandra production cluster, RabbitMQ event pipelines, and Elasticsearch/OpenSearch analytics infrastructure.",
              "Owned data modeling across Cassandra and PostgreSQL; routinely debugged and optimized high-volume transaction paths, production SQL, and reporting workloads.",
              "Built Apache Spark (Scala, AWS EMR) pipelines that aggregated Cassandra raw event data into PostgreSQL datasets used for analytics and financial reporting.",
              "Architected and built NetAdmin, an internal Elixir platform using Phoenix, LiveView, and Ash Framework for resource lifecycle orchestration, distributed systems monitoring, operational auditability, and cross-system automation.",
              "Owned system reliability across BEAM VM tuning, relup strategy, CI/CD automation, Ansible-based infrastructure automation, and production incident debugging in distributed environments.",
              "Led and managed up to 5 engineers across UI and infrastructure while remaining hands-on in backend development, data architecture, and full-stack delivery. Conducted technical interviews and hiring evaluations.",
              "Managed cloud and infrastructure operations across AWS, domains, and VPS providers, and implemented audits and scaling changes that reduced infrastructure operating costs by ~25%."
            ]}
          />
          <.experience_card
            id="experience-revenuelink"
            title="Founder & Software Engineer"
            company="RevenueLink Technologies LLC"
            period="2023 — Present"
            current?={true}
            items={[
              "Founded a consulting and software vehicle for independent projects, select consulting engagements, and Elixir/Phoenix experiments.",
              {:parts,
               [
                 {:text, "Designed and built "},
                 {:link, "https://hardcorehandyman.fly.dev/", "hardcorehandyman.fly.dev"},
                 {:text,
                  ", a custom Phoenix LiveView lead-generation platform for a local handyman business. The system included SEO-driven service pages, a quote workflow with photo uploads, and an internal admin interface for managing requests. "},
                 {:strong,
                  "The platform ultimately generated more inbound demand than the business could operationally support."}
               ]},
              {:parts,
               [
                 {:text, "Built and operate "},
                 {:link, "https://revstack.fly.dev/", "revstack.fly.dev"},
                 {:text,
                  ", a Phoenix LiveView application serving as a recruiter-facing portfolio, lead-generation platform, and sandbox for new ideas."}
               ]},
              "Use the company as a vehicle for consulting, hands-on product work, and experimentation with Elixir, infrastructure tooling, and small SaaS-style projects."
            ]}
          />
          <.experience_card
            title="Application Programmer"
            company="CGI Federal"
            period="December 2013 — October 2014"
            current?={false}
            items={[
              "Performed detailed source code analysis for enterprise Java/ADA systems.",
              "Developed tooling and assisted with build/release workflows for multi-million SLOC applications.",
              "Created smoke and sanity testing processes supporting production releases."
            ]}
          />
          <.experience_card
            title="In-House Technician"
            company="Wichita Online"
            period="April 2013 — December 2013"
            current?={false}
            items={[
              "Provided in-field network troubleshooting and wireless equipment deployment (MikroTik, Canopy routers)."
            ]}
          />
        </div>
      </div>
    </section>
    """
  end

  defp career_portfolio_section(assigns) do
    ~H"""
    <section
      id="whoami-portfolio"
      class="section-card py-16 sm:py-20 bg-base-200/30 px-4 sm:px-6 lg:px-8 scroll-mt-24"
    >
      <div class="mx-auto max-w-5xl">
        <div class="text-center mb-12">
          <h2 class="text-3xl font-bold text-base-content">Career Portfolio</h2>
          <div class="mt-3 w-16 h-1 bg-primary mx-auto rounded-full"></div>
          <p class="mt-4 text-base text-base-content/70 max-w-2xl mx-auto">
            The affiliate platform is the centerpiece of my career story, and NetAdmin is the major
            Elixir platform I built alongside it. Supporting systems are grouped the way they were
            actually owned in production. <br />
            <.icon
              name="hero-cursor-arrow-rays"
              class="size-7 inline-block align-text-bottom"
            /><b class="text-lg">click a phase to explore the systems and projects behind it.</b>
          </p>
        </div>
        <div class="space-y-6">
          <%= for phase <- @career_phases do %>
            <.career_standout_phase_card
              phase={phase}
              expanded?={@expanded_phase_id == phase.id}
            />
          <% end %>
        </div>
      </div>
    </section>
    """
  end

  defp live_projects_section(assigns) do
    ~H"""
    <section id="live-projects" class="section-card py-16 sm:py-20 px-4 sm:px-6 lg:px-8 scroll-mt-24">
      <div class="mx-auto max-w-5xl">
        <div class="text-center mb-14">
          <%!-- <div class="inline-flex items-center gap-2 rounded-full bg-primary/10 px-4 py-1.5 text-sm font-medium text-primary mb-4">
            <.icon name="hero-rocket-launch" class="size-4" /> Live &amp; Deployed
          </div> --%>
          <h2 class="text-3xl sm:text-4xl font-bold text-base-content">Personal Live Projects</h2>
          <div class="mt-3 w-16 h-1 bg-primary mx-auto rounded-full"></div>
          <p class="mt-4 text-base text-base-content/70 max-w-2xl mx-auto">
            Recent side projects and deployed experiments outside the affiliate platform and NetAdmin work.
            <br />
            <.icon
              name="hero-cursor-arrow-rays"
              class="size-5 inline-block align-text-bottom"
            /><b class="text-lg">click a project to explore.</b>
          </p>
        </div>

        <div class="grid grid-cols-1 lg:grid-cols-3 gap-8">
          <.project_card
            id="project-handyman"
            title="Hardcore Handyman"
            subtitle="Phoenix LiveView lead-generation system with quote requests, photo uploads, SEO-driven service pages, and an admin workflow that generated more demand than the business could operationally support."
            href="https://hardcorehandyman.fly.dev/"
            icon="hero-wrench-screwdriver"
            preview_src={~p"/images/hardcorehandyman_preview.png"}
            tech={~w(Elixir Phoenix LiveView Ecto Swoosh Fly.io)}
          />
          <.project_card
            id="project-admin"
            title="Revstack Admin Dashboard"
            subtitle="Internal Phoenix LiveView admin surface for managing leads and estimates, with real-time data grids, filtering, status workflows, and authenticated operations."
            href="https://github.com/kyle-neal/revstack"
            icon="hero-cog-6-tooth"
            preview_src={~p"/images/admin_panel/admin_dashboard.png"}
            tech={["Elixir", "Phoenix", "LiveView", "Ash Framework", "Postgres"]}
            on_click="open_admin_gallery"
          />
          <.project_card
            id="project-revenuelink"
            title="RevenueLink"
            subtitle="Consulting and business site for RevenueLink Technologies, used as a public home for services, projects, and lightweight product experiments."
            href="https://revenuelink.net/"
            icon="hero-building-office-2"
            preview_src={~p"/images/revenuelink_preview.png"}
            tech={~w(Next.js ReactJS TailwindCSS Vercel)}
          />
        </div>
      </div>
    </section>
    """
  end

  defp education_section(assigns) do
    ~H"""
    <section
      id="whoami-education"
      class="section-card py-16 sm:py-20 px-4 sm:px-6 lg:px-8 scroll-mt-24"
    >
      <div class="mx-auto max-w-4xl">
        <div class="text-center mb-12">
          <h2 class="text-3xl font-bold text-base-content">Education</h2>
          <div class="mt-3 w-16 h-1 bg-primary mx-auto rounded-full"></div>
        </div>
        <div class="grid grid-cols-1 sm:grid-cols-2 gap-6">
          <.education_card
            degree="B.S. Computer Science"
            school="Cameron University"
            period="Fall 2010 — July 2014"
            honors="Magna Cum Laude"
          />
          <.education_card
            degree="A.S. Information Technology"
            school="Cameron University"
            period="Fall 2012 — June 2014"
            honors="Magna Cum Laude"
          />
        </div>
      </div>
    </section>
    """
  end

  defp leadership_and_teamwork_section(assigns) do
    ~H"""
    <section
      id="leadership-teamwork"
      class="section-card py-16 sm:py-20 bg-base-200/30 px-4 sm:px-6 lg:px-8 scroll-mt-24"
    >
      <div class="mx-auto max-w-5xl">
        <div class="text-center mb-12">
          <h2 class="text-3xl font-bold text-base-content">Leadership &amp; Teamwork</h2>
          <div class="mt-3 w-16 h-1 bg-primary mx-auto rounded-full"></div>
          <p class="mt-4 max-w-3xl mx-auto text-base text-base-content/70 leading-relaxed">
            Hands-on technical leadership across backend, infrastructure, and delivery. I stayed
            responsible for architecture and production systems while leading engineers, hiring, and
            driving operational decisions.
          </p>
        </div>

        <%!-- Leadership highlights --%>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 mb-8">
          <.leadership_item
            icon="hero-building-office"
            text="Long-term ownership of revenue-critical backend platforms"
          />
          <.leadership_item
            icon="hero-academic-cap"
            text="Led, mentored, and managed up to 5 engineers"
          />
          <.leadership_item
            icon="hero-user-plus"
            text="Conducted technical interviews and engineering evaluations"
          />
          <.leadership_item
            icon="hero-arrow-trending-up"
            text="Scaled systems supporting $2.5M+ monthly revenue"
          />
          <.leadership_item
            icon="hero-calendar"
            text="Managed releases, incidents, and infrastructure operations"
          />
          <.leadership_item
            icon="hero-wrench-screwdriver"
            text="Reduced infrastructure operating costs by ~25%"
          />
        </div>

        <%!-- Team collaboration cards --%>
        <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div
            id="teamwork-poland"
            class="rounded-2xl border border-base-300 bg-base-100 p-6 shadow-sm hover:shadow-md transition-shadow duration-200"
          >
            <div class="flex items-center gap-3 mb-4">
              <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary">
                <.icon name="hero-user-group" class="size-5" />
              </div>
              <div>
                <h3 class="text-lg font-bold text-base-content">Affiliate Platform Ownership</h3>
                <p class="text-sm text-base-content/60">
                  Distributed backend and operations collaboration
                </p>
              </div>
            </div>

            <ul class="space-y-3">
              <li class="flex items-start gap-2.5 text-sm text-base-content/80 leading-relaxed">
                <.icon name="hero-chevron-right" class="size-4 text-primary shrink-0 mt-0.5" />
                <span>
                  Partnered with backend and infrastructure engineers across multiple stages of the
                  platform, then became the long-term owner of backend architecture, features, and
                  production operations.
                </span>
              </li>
              <li class="flex items-start gap-2.5 text-sm text-base-content/80 leading-relaxed">
                <.icon name="hero-chevron-right" class="size-4 text-primary shrink-0 mt-0.5" />
                <span>
                  Worked directly with the CTO on business rules, partner integrations, reporting
                  requirements, and production decision-making for the affiliate platform.
                </span>
              </li>
              <li class="flex items-start gap-2.5 text-sm text-base-content/80 leading-relaxed">
                <.icon name="hero-chevron-right" class="size-4 text-primary shrink-0 mt-0.5" />
                <span>
                  Rewrote and expanded major portions of the system over time while keeping the
                  platform live, revenue-critical, and operationally stable.
                </span>
              </li>
            </ul>
          </div>

          <div
            id="teamwork-ph-infra"
            class="rounded-2xl border border-base-300 bg-base-100 p-6 shadow-sm hover:shadow-md transition-shadow duration-200"
          >
            <div class="flex items-center gap-3 mb-4">
              <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary">
                <.icon name="hero-wrench-screwdriver" class="size-5" />
              </div>
              <div>
                <h3 class="text-lg font-bold text-base-content">Infrastructure Team</h3>
                <p class="text-sm text-base-content/60">
                  Hands-on infrastructure and operational leadership
                </p>
              </div>
            </div>

            <ul class="space-y-3">
              <li class="flex items-start gap-2.5 text-sm text-base-content/80 leading-relaxed">
                <.icon name="hero-chevron-right" class="size-4 text-primary shrink-0 mt-0.5" />
                <span>
                  Led up to <b>3 infrastructure engineers</b>
                  and <b>2 UI engineers</b>
                  while still owning critical backend architecture, reliability work, and escalations.
                </span>
              </li>
              <li class="flex items-start gap-2.5 text-sm text-base-content/80 leading-relaxed">
                <.icon name="hero-chevron-right" class="size-4 text-primary shrink-0 mt-0.5" />
                <span>
                  Managed AWS, VPS, domain, and operational cost decisions directly, including audits
                  and scaling changes that lowered infrastructure spend by <b>~25%</b>.
                </span>
              </li>
            </ul>
          </div>
        </div>
      </div>
    </section>
    """
  end

  defp personal_interests_section(assigns) do
    ~H"""
    <section
      id="whoami-interests"
      class="section-card py-16 sm:py-20 bg-base-200/30 px-4 sm:px-6 lg:px-8 scroll-mt-24"
    >
      <div class="mx-auto max-w-4xl">
        <div class="text-center mb-12">
          <h2 class="text-3xl font-bold text-base-content">When I'm Not Coding</h2>
          <div class="mt-3 w-16 h-1 bg-primary mx-auto rounded-full"></div>
        </div>
        <div class="flex flex-wrap justify-center gap-4">
          <.interest_badge icon="hero-musical-note" label="Playing Guitar" />
          <.interest_badge icon="hero-fire" label="Mountain Biking" />
          <.interest_badge icon="hero-map" label="Hiking" />
          <.interest_badge icon="hero-globe-americas" label="Going on Adventures" />
          <.interest_badge icon="hero-light-bulb" label="Learning New Things" />
        </div>
      </div>
    </section>
    """
  end

  defp closing_cta_section(assigns) do
    ~H"""
    <section id="whoami-contact" class="py-20 sm:py-28 scroll-mt-24">
      <div class="mx-auto max-w-3xl">
        <div class="flex flex-col sm:flex-row justify-center gap-6">
          <!-- Primary: Hiring -->
          <div class="group rounded-2xl border border-primary/20 bg-primary/5 p-8 text-center shadow-sm hover:shadow-md hover:border-primary/40 transition-all duration-300">
            <div class="flex h-14 w-14 items-center justify-center rounded-2xl bg-primary/15 text-primary mx-auto mb-4 group-hover:bg-primary/25 transition-colors">
              <.icon name="hero-briefcase" class="size-7" />
            </div>

            <h3 class="text-lg font-bold text-base-content mb-2">
              Hiring for a remote role?
            </h3>

            <p class="text-sm text-base-content/70 mb-4">
              Open to the right Erlang/Elixir, platform, or distributed systems opportunity.
            </p>

            <.link navigate={~p"/contact"} class="btn btn-primary gap-2">
              <.icon name="hero-envelope" class="size-4" /> Get in Touch
            </.link>
          </div>
          <!-- Secondary: Consulting -->
          <div class="group rounded-2xl border border-base-300 bg-base-100 p-8 text-center shadow-sm hover:shadow-md hover:border-primary/30 transition-all duration-300">
            <div class="flex h-14 w-14 items-center justify-center rounded-2xl bg-base-200 text-base-content mx-auto mb-4 group-hover:bg-base-300 transition-colors">
              <.icon name="hero-wrench-screwdriver" class="size-7" />
            </div>

            <h3 class="text-lg font-bold text-base-content mb-2">
              Need consulting or project work?
            </h3>

            <p class="text-sm text-base-content/70 mb-4">
              I occasionally take on consulting and small project engagements.
            </p>

            <.link navigate={~p"/services"} class="btn btn-outline gap-2">
              <.icon name="hero-briefcase" class="size-4" /> View Services
            </.link>
          </div>
        </div>
      </div>
    </section>
    """
  end

  defp github_repository_section(assigns) do
    ~H"""
    <section id="whoami-source" class="pb-20 scroll-mt-24">
      <div class="mx-auto max-w-3xl">
        <div class="rounded-2xl border border-base-300 bg-base-200/50 p-8 text-center">
          <div class="flex h-14 w-14 items-center justify-center rounded-2xl bg-base-content/10 mx-auto mb-4">
            <svg
              viewBox="0 0 16 16"
              class="size-7 fill-current text-base-content"
              aria-hidden="true"
            >
              <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z" />
            </svg>
          </div>
          <h3 class="text-lg font-bold text-base-content mb-2">View the Source Code</h3>
          <p class="text-sm text-base-content/70 mb-4 max-w-md mx-auto">
            This portfolio site is open source. Check out the code on GitHub to see how it's built with Phoenix LiveView.
          </p>
          <a
            href="https://github.com/kyle-neal/revstack"
            target="_blank"
            rel="noopener noreferrer"
            class="btn btn-outline gap-2 transition-all duration-300 hover:-translate-y-0.5"
          >
            <svg viewBox="0 0 16 16" class="size-4 fill-current" aria-hidden="true">
              <path d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0016 8c0-4.42-3.58-8-8-8z" />
            </svg>
            View on GitHub
          </a>
        </div>
      </div>
    </section>
    """
  end

  defp project_card(assigns) do
    assigns =
      assigns
      |> assign_new(:preview_src, fn -> nil end)
      |> assign_new(:preview_alt, fn -> "#{assigns.title} preview" end)
      |> assign_new(:tech, fn -> [] end)
      |> assign_new(:on_click, fn -> nil end)

    ~H"""
    <%= if @on_click do %>
      <button
        id={@id}
        phx-click={@on_click}
        class="group block w-full text-left rounded-2xl border border-base-300 bg-base-100 shadow-sm hover:shadow-xl hover:border-primary/40 transition-all duration-300 hover:-translate-y-1 overflow-hidden"
      >
        <div class="overflow-hidden bg-base-200/40 aspect-video relative">
          <%= if @preview_src do %>
            <img
              src={@preview_src}
              alt={@preview_alt}
              loading="lazy"
              class="h-full w-full object-cover object-top group-hover:scale-[1.03] transition-transform duration-500"
            />
          <% else %>
            <div class="flex h-full w-full items-center justify-center text-base-content/40">
              <.icon name="hero-photo" class="size-8" />
            </div>
          <% end %>
          <div class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-end justify-center pb-4">
            <span class="text-white text-sm font-medium flex items-center gap-1.5">
              <.icon name="hero-eye" class="size-4" /> View Screenshots
            </span>
          </div>
        </div>
        <div class="p-5">
          <div class="flex items-start justify-between gap-3">
            <div class="min-w-0">
              <h3 class="text-lg font-bold text-base-content group-hover:text-primary transition-colors duration-200">
                {@title}
              </h3>
              <p class="mt-1.5 text-sm text-base-content/70 leading-relaxed line-clamp-3">
                {@subtitle}
              </p>
            </div>
            <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary group-hover:bg-primary group-hover:text-white transition-all duration-300">
              <.icon name={@icon} class="size-5" />
            </div>
          </div>
          <div :if={@tech != []} class="mt-4 flex flex-wrap gap-1.5">
            <span
              :for={t <- @tech}
              class={[
                "inline-block rounded-md bg-base-200 px-2 py-0.5 text-xs font-medium text-base-content/70",
                tech_badge_modifier_classes(t)
              ]}
            >
              {t}
            </span>
          </div>
          <p :if={@href} class="mt-3 text-xs text-primary font-medium truncate">{@href}</p>
        </div>
      </button>
    <% else %>
      <a
        id={@id}
        href={@href}
        target="_blank"
        rel="noopener noreferrer"
        class="group block rounded-2xl border border-base-300 bg-base-100 shadow-sm hover:shadow-xl hover:border-primary/40 transition-all duration-300 hover:-translate-y-1 overflow-hidden"
      >
        <div class="overflow-hidden bg-base-200/40 aspect-video relative">
          <%= if @preview_src do %>
            <img
              src={@preview_src}
              alt={@preview_alt}
              loading="lazy"
              class="h-full w-full object-cover object-top group-hover:scale-[1.03] transition-transform duration-500"
            />
          <% else %>
            <div class="flex h-full w-full items-center justify-center text-base-content/40">
              <.icon name="hero-photo" class="size-8" />
            </div>
          <% end %>
          <div class="absolute inset-0 bg-gradient-to-t from-black/60 via-transparent to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300 flex items-end justify-center pb-4">
            <span class="text-white text-sm font-medium flex items-center gap-1.5">
              <.icon name="hero-arrow-top-right-on-square" class="size-4" /> Visit Site
            </span>
          </div>
        </div>
        <div class="p-5">
          <div class="flex items-start justify-between gap-3">
            <div class="min-w-0">
              <h3 class="text-lg font-bold text-base-content group-hover:text-primary transition-colors duration-200">
                {@title}
              </h3>
              <p class="mt-1.5 text-sm text-base-content/70 leading-relaxed line-clamp-3">
                {@subtitle}
              </p>
            </div>
            <div class="flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary group-hover:bg-primary group-hover:text-white transition-all duration-300">
              <.icon name={@icon} class="size-5" />
            </div>
          </div>
          <div :if={@tech != []} class="mt-4 flex flex-wrap gap-1.5">
            <span
              :for={t <- @tech}
              class={[
                "inline-block rounded-md bg-base-200 px-2 py-0.5 text-xs font-medium text-base-content/70",
                tech_badge_modifier_classes(t)
              ]}
            >
              {t}
            </span>
          </div>
          <p class="mt-3 text-xs text-primary font-medium truncate">{@href}</p>
        </div>
      </a>
    <% end %>
    """
  end

  defp section_navigation_toggle(assigns) do
    ~H"""
    <button
      id="section-nav-toggle"
      phx-click="toggle_section_nav"
      aria-label="Toggle section navigation"
      aria-expanded={@menu_open?}
      class="inline-flex h-10 w-10 items-center justify-center rounded-xl border border-base-300 bg-base-100 text-base-content/80 shadow-sm transition-all duration-200 hover:border-primary/40 hover:text-primary"
    >
      <.icon name="hero-bars-3" class="size-5" />
    </button>
    """
  end

  defp section_navigation_panel(assigns) do
    ~H"""
    <div id="section-nav" class="fixed left-3 top-16 z-40 sm:left-5 sm:top-20">
      <div
        id="section-nav-panel"
        class="w-[min(85vw,20rem)] rounded-2xl border border-base-300 bg-base-100/95 p-3 shadow-2xl backdrop-blur"
      >
        <div class="mb-2 flex items-center justify-between gap-3 px-1">
          <p class="text-xs font-bold uppercase tracking-wide text-primary">Jump to Section</p>
          <button
            id="section-nav-close"
            phx-click="close_section_nav"
            class="inline-flex h-7 w-7 items-center justify-center rounded-md text-base-content/60 hover:bg-base-200 hover:text-base-content transition-colors"
            aria-label="Close section navigation"
          >
            <.icon name="hero-x-mark" class="size-4" />
          </button>
        </div>
        <nav id="section-nav-links" class="max-h-[60vh] overflow-y-auto pr-1">
          <a
            :for={item <- @items}
            id={"section-nav-link-#{item.id}"}
            href={"##{item.id}"}
            phx-click="close_section_nav"
            class="block rounded-lg px-3 py-2 text-sm font-medium text-base-content/75 transition-colors hover:bg-primary/10 hover:text-primary"
          >
            {item.label}
          </a>
        </nav>
      </div>
    </div>
    """
  end

  defp admin_gallery_modal(assigns) do
    images = assigns.images
    current = Enum.at(images, assigns.current_index)
    total = length(images)

    assigns =
      assign(assigns,
        current_image: current,
        total: total
      )

    ~H"""
    <div
      id="admin-gallery-modal"
      class="fixed inset-0 z-50 overflow-y-auto"
      phx-window-keydown="close_admin_gallery"
      phx-key="Escape"
      phx-hook="LockBodyScroll"
    >
      <div
        class="fixed inset-0 bg-black/70 backdrop-blur-sm"
        phx-click="close_admin_gallery"
      >
      </div>
      <div class="relative flex min-h-full items-start justify-center p-4 sm:p-6 lg:p-8">
        <div class="relative w-full max-w-5xl my-8 rounded-2xl border border-base-300 bg-base-100 shadow-2xl">
          <%!-- Header --%>
          <div class="sticky top-0 z-10 flex items-center justify-between gap-4 rounded-t-2xl border-b border-base-300 bg-base-100/95 backdrop-blur px-6 py-4">
            <div class="flex items-center gap-3 min-w-0">
              <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
                <.icon name="hero-cog-6-tooth" class="size-5" />
              </div>
              <div class="min-w-0">
                <h3 class="font-bold text-base-content truncate">Admin Panel Screenshots</h3>
                <p class="text-xs text-base-content/50">
                  {@current_index + 1} of {@total} — {@current_image.title}
                </p>
              </div>
            </div>
            <button
              id="close-admin-gallery"
              phx-click="close_admin_gallery"
              class="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg hover:bg-base-200 transition-colors"
              aria-label="Close gallery"
            >
              <.icon name="hero-x-mark" class="size-5" />
            </button>
          </div>

          <%!-- Main Image --%>
          <div class="p-6">
            <div class="relative rounded-xl overflow-hidden admin-screenshot-glow">
              <img
                src={@current_image.src}
                alt={@current_image.title}
                class="w-full rounded-xl"
              />
              <%!-- Navigation arrows --%>
              <button
                :if={@current_index > 0}
                id="admin-gallery-prev"
                phx-click="admin_gallery_prev"
                class="absolute left-3 top-1/2 -translate-y-1/2 flex h-10 w-10 items-center justify-center rounded-full bg-black/50 text-white hover:bg-black/70 transition-colors backdrop-blur-sm"
                aria-label="Previous screenshot"
              >
                <.icon name="hero-chevron-left" class="size-5" />
              </button>
              <button
                :if={@current_index < @total - 1}
                id="admin-gallery-next"
                phx-click="admin_gallery_next"
                class="absolute right-3 top-1/2 -translate-y-1/2 flex h-10 w-10 items-center justify-center rounded-full bg-black/50 text-white hover:bg-black/70 transition-colors backdrop-blur-sm"
                aria-label="Next screenshot"
              >
                <.icon name="hero-chevron-right" class="size-5" />
              </button>
            </div>

            <%!-- Description --%>
            <div class="mt-5 text-center">
              <h4 class="text-lg font-bold text-base-content">{@current_image.title}</h4>
              <p class="mt-1.5 text-sm text-base-content/70 max-w-2xl mx-auto">
                {@current_image.description}
              </p>
            </div>

            <%!-- Thumbnail strip --%>
            <div class="mt-6 flex justify-center gap-2 overflow-x-auto pb-2">
              <%= for {img, idx} <- Enum.with_index(@images) do %>
                <button
                  phx-click="admin_gallery_select"
                  phx-value-index={idx}
                  class={[
                    "shrink-0 w-20 h-14 rounded-lg overflow-hidden border-2 transition-all duration-200 hover:opacity-100",
                    if(idx == @current_index,
                      do: "border-primary ring-2 ring-primary/30 opacity-100",
                      else: "border-transparent opacity-60 hover:border-base-300"
                    )
                  ]}
                >
                  <img
                    src={img.src}
                    alt={img.title}
                    class="h-full w-full object-cover object-top"
                  />
                </button>
              <% end %>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp stat_card(assigns) do
    assigns =
      assigns
      |> assign(:headline, Map.get(assigns, :headline, Map.get(assigns, :label)))
      |> assign_new(:detail, fn -> nil end)

    ~H"""
    <div class="rounded-2xl border border-base-300 bg-base-100 px-5 py-6 text-center shadow-sm hover:shadow-md hover:border-primary/30 transition-all duration-200">
      <p class="text-3xl sm:text-4xl font-extrabold tracking-tight text-primary">{@value}</p>
      <p class="mt-2 text-sm sm:text-base font-semibold leading-snug text-base-content">
        {@headline}
      </p>
      <p :if={@detail} class="mt-1 text-[11px] sm:text-xs leading-relaxed text-base-content/55">
        {@detail}
      </p>
    </div>
    """
  end

  defp summary_item(assigns) do
    ~H"""
    <div class="flex items-start gap-3 rounded-xl border border-base-300 bg-base-100 p-4 shadow-sm">
      <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
        <.icon name={@icon} class="size-4" />
      </div>
      <p class="text-sm text-base-content/80 leading-relaxed">{@text}</p>
    </div>
    """
  end

  defp expertise_group(assigns) do
    ~H"""
    <div class="rounded-2xl border border-base-300 bg-base-100 p-6 shadow-sm">
      <h3 class="font-bold text-primary mb-4">{@title}</h3>
      <ul class="space-y-2">
        <li :for={item <- @items} class="flex items-start gap-2 text-sm text-base-content/80">
          <.icon name="hero-check" class="size-4 text-primary shrink-0 mt-0.5" />
          <span>{item}</span>
        </li>
      </ul>
    </div>
    """
  end

  defp experience_card(assigns) do
    assigns = assign_new(assigns, :id, fn -> nil end)

    ~H"""
    <div
      id={@id}
      class="rounded-2xl border border-base-300 bg-base-100 p-6 sm:p-8 shadow-sm hover:shadow-md transition-shadow duration-200"
    >
      <div class="flex flex-col sm:flex-row sm:items-start sm:justify-between gap-2 mb-5">
        <div>
          <h3 class="text-lg font-bold text-base-content">{@title}</h3>
          <p class="text-primary font-medium">{@company}</p>
        </div>
        <div class="flex items-center gap-2 shrink-0">
          <span class="text-sm text-base-content/60">{@period}</span>
          <span
            :if={@current?}
            class="inline-flex items-center rounded-full bg-success/10 px-2.5 py-0.5 text-xs font-medium text-success"
          >
            Current
          </span>
        </div>
      </div>
      <ul class="space-y-3">
        <li
          :for={item <- @items}
          class="flex items-start gap-2.5 text-sm text-base-content/80 leading-relaxed"
        >
          <.icon name="hero-chevron-right" class="size-4 text-primary shrink-0 mt-0.5" />
          <.experience_item item={item} />
        </li>
      </ul>
    </div>
    """
  end

  defp experience_item(%{item: item} = assigns) when is_binary(item) do
    ~H"<span>{@item}</span>"
  end

  defp experience_item(%{item: {:parts, parts}} = assigns) do
    assigns = assign(assigns, :parts, parts)

    ~H"""
    <span>
      <%= for part <- @parts do %>
        <%= case part do %>
          <% {:text, text} -> %>
            {text}
          <% {:link, url, label} -> %>
            <a
              href={url}
              target="_blank"
              rel="noopener noreferrer"
              class="text-primary hover:underline font-medium inline-flex items-center gap-0.5"
            >
              {label}<.icon name="hero-arrow-top-right-on-square" class="size-3 ml-0.5 shrink-0" />
            </a>
          <% {:strong, text} -> %>
            <strong class="experience-emphasis font-semibold text-base-content">{text}</strong>
        <% end %>
      <% end %>
    </span>
    """
  end

  defp education_card(assigns) do
    ~H"""
    <div class="rounded-2xl border border-base-300 bg-base-100 p-6 shadow-sm text-center hover:shadow-md hover:border-primary/30 transition-all duration-200">
      <div class="flex h-12 w-12 items-center justify-center rounded-xl bg-primary/10 text-primary mx-auto mb-4">
        <.icon name="hero-academic-cap" class="size-6" />
      </div>
      <h3 class="font-bold text-base-content">{@degree}</h3>
      <p class="text-sm text-base-content/70 mt-1">{@school}</p>
      <p class="text-xs text-base-content/50 mt-1">{@period}</p>
      <span class="inline-flex items-center rounded-full bg-primary/10 px-3 py-1 text-xs font-medium text-primary mt-3">
        {@honors}
      </span>
    </div>
    """
  end

  defp leadership_item(assigns) do
    ~H"""
    <div class="flex items-center gap-3 rounded-xl border border-base-300 bg-base-100 p-4 shadow-sm">
      <div class="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg bg-primary/10 text-primary">
        <.icon name={@icon} class="size-4" />
      </div>
      <span class="text-sm font-medium text-base-content">{@text}</span>
    </div>
    """
  end

  defp interest_badge(assigns) do
    ~H"""
    <div class="flex items-center gap-2 rounded-full border border-base-300 bg-base-100 px-5 py-3 shadow-sm hover:shadow-md hover:border-primary/30 transition-all duration-200">
      <.icon name={@icon} class="size-5 text-primary" />
      <span class="text-sm font-medium text-base-content">{@label}</span>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Career Portfolio Components
  # ---------------------------------------------------------------------------

  defp career_standout_phase_card(assigns) do
    ~H"""
    <div id={"career-phase-#{@phase.id}"} class="group/phase">
      <%!-- Phase Card (Layer 1) --%>
      <button
        phx-click={if @expanded?, do: "collapse_career_phase", else: "expand_career_phase"}
        phx-value-phase-id={@phase.id}
        class={[
          "w-full text-left rounded-2xl border-2 p-6 sm:p-8 transition-all duration-300 cursor-pointer",
          if(@expanded?,
            do: "border-primary bg-primary/5 shadow-lg",
            else:
              "border-base-300 bg-base-100 shadow-sm hover:shadow-xl hover:border-primary/40 hover:-translate-y-0.5"
          )
        ]}
      >
        <div class="flex items-start gap-5">
          <%!-- Phase Icon --%>
          <div class={[
            "flex h-14 w-14 sm:h-16 sm:w-16 shrink-0 items-center justify-center rounded-2xl transition-colors duration-300",
            if(@expanded?,
              do: "bg-primary text-white",
              else: "bg-primary/10 text-primary group-hover/phase:bg-primary/20"
            )
          ]}>
            <.icon name={@phase.card_icon} class="size-7 sm:size-8" />
          </div>

          <%!-- Phase Content --%>
          <div class="flex-1 min-w-0">
            <div class="flex items-center justify-between gap-4">
              <div>
                <h3 class="text-xl sm:text-2xl font-extrabold text-base-content leading-tight">
                  {@phase.card_title}
                </h3>
                <p class="mt-1 text-sm text-base-content/50 font-medium">{@phase.card_era}</p>
              </div>
              <div class={[
                "flex h-10 w-10 shrink-0 items-center justify-center rounded-full transition-all duration-300",
                if(@expanded?,
                  do: "bg-primary text-white rotate-180",
                  else:
                    "bg-base-200 text-base-content/40 group-hover/phase:bg-primary/10 group-hover/phase:text-primary"
                )
              ]}>
                <.icon name="hero-chevron-down" class="size-5" />
              </div>
            </div>

            <p class="mt-3 text-sm sm:text-base text-base-content/70 leading-relaxed max-w-3xl">
              {@phase.card_summary}
            </p>

            <%!-- Skill Badges --%>
            <div class="mt-4 flex flex-wrap gap-2">
              <span
                :for={badge <- @phase.card_badges}
                class={[
                  "skill-badge inline-flex items-center gap-1.5 rounded-full border px-3 py-1 text-xs font-semibold transition-colors",
                  career_phase_badge_modifier_classes(badge),
                  if(@expanded?,
                    do: "ring-1 ring-primary/15",
                    else: "group-hover/phase:-translate-y-0.5"
                  )
                ]}
              >
                {badge}
              </span>
            </div>

            <%!-- Key Bullets --%>
            <ul class="mt-4 space-y-1.5">
              <li
                :for={bullet <- @phase.card_bullets}
                class="flex items-start gap-2 text-sm text-base-content/70"
              >
                <.icon name="hero-check" class="size-4 text-primary shrink-0 mt-0.5" />
                <span>{bullet}</span>
              </li>
            </ul>

            <%!-- CTA hint --%>
            <div
              :if={!@expanded?}
              class="mt-5 inline-flex items-center gap-1.5 text-sm font-semibold text-primary"
            >
              <.icon name="hero-cursor-arrow-rays" class="size-4" />
              Explore {length(@phase.projects)} projects
              <.icon name="hero-chevron-right" class="size-4" />
            </div>
          </div>
        </div>
      </button>

      <%!-- Expanded Phase Content (Layer 2) --%>
      <div
        :if={@expanded?}
        class="mt-4 ml-2 pl-6 border-l-2 border-primary/20 space-y-8 animate-fade-in"
      >
        <p
          :if={Map.get(@phase, :overview)}
          class="text-sm text-base-content/70 leading-relaxed max-w-3xl"
        >
          {@phase.overview}
        </p>
        <.phase_scale_metrics :if={Map.get(@phase, :metrics)} metrics={@phase.metrics} />
        <div :if={Map.get(@phase, :featured_project_ids)} id={"career-featured-#{@phase.id}"}>
          <p class="text-sm font-bold text-primary uppercase tracking-wide mb-4">
            Flagship systems
          </p>
          <div class="grid grid-cols-1 lg:grid-cols-2 gap-4">
            <.career_project_card
              :for={project <- phase_projects(@phase, Map.get(@phase, :featured_project_ids, []))}
              project={project}
              featured?={true}
            />
          </div>
        </div>
        <div
          :if={Map.get(@phase, :project_groups)}
          id={"career-groups-#{@phase.id}"}
          class="space-y-4"
        >
          <.career_project_group
            :for={group <- @phase.project_groups}
            phase={@phase}
            group={group}
          />
        </div>
        <div :if={!Map.get(@phase, :project_groups)}>
          <p class="text-sm font-bold text-primary uppercase tracking-wide mb-4">
            <.icon name="hero-cursor-arrow-rays" class="size-4 inline-block align-text-bottom" />
            Click any project for the full story
          </p>
          <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            <.career_project_card :for={project <- @phase.projects} project={project} />
          </div>
        </div>
        <.phase_team_section :if={Map.get(@phase, :team)} team={@phase.team} />
      </div>
    </div>
    """
  end

  defp phase_scale_metrics(assigns) do
    ~H"""
    <div class="mb-8">
      <div class="flex flex-wrap gap-2.5">
        <div
          :for={metric <- @metrics}
          class="flex items-center gap-2 rounded-full border border-primary/20 bg-primary/5 px-3.5 py-1.5"
        >
          <span class="text-sm font-bold text-primary">{metric.value}</span>
          <span class="text-xs text-base-content/60">{metric.label}</span>
        </div>
      </div>
    </div>
    """
  end

  defp phase_team_section(assigns) do
    ~H"""
    <div class="mt-8 rounded-2xl border border-base-300 bg-base-100 p-6 shadow-sm">
      <div class="flex items-center gap-3 mb-4">
        <div class="flex h-8 w-8 items-center justify-center rounded-lg bg-primary/10 text-primary shrink-0">
          <.icon name="hero-user-group" class="size-4" />
        </div>
        <h4 class="text-sm font-bold text-primary uppercase tracking-wide">Team & Leadership</h4>
      </div>
      <p class="text-sm text-base-content/80 leading-relaxed mb-4">{@team.description}</p>
      <ul class="space-y-2">
        <li
          :for={item <- @team.members}
          class="flex items-start gap-2.5 text-sm text-base-content/70 leading-relaxed"
        >
          <.icon name="hero-chevron-right" class="size-4 text-primary shrink-0 mt-0.5" />
          <span>{item}</span>
        </li>
      </ul>
    </div>
    """
  end

  defp career_project_card(assigns) do
    assigns = assign_new(assigns, :featured?, fn -> false end)

    ~H"""
    <button
      id={"career-project-card-#{@project.id}"}
      phx-click="open_career_modal"
      phx-value-project-id={@project.id}
      class={[
        "group text-left rounded-2xl border p-5 transition-all duration-200 cursor-pointer w-full",
        if(@featured?,
          do: "border-primary/20 bg-primary/5 shadow-md hover:shadow-lg hover:border-primary/40",
          else: "border-base-300 bg-base-100 shadow-sm hover:shadow-md hover:border-primary/30"
        )
      ]}
    >
      <div :if={Map.get(@project, :featured_label)} class="mb-3">
        <span class="inline-flex items-center rounded-full bg-primary px-2.5 py-1 text-[11px] font-bold uppercase tracking-wide text-white">
          {@project.featured_label}
        </span>
      </div>
      <div class="flex items-center gap-3 mb-3">
        <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary group-hover:bg-primary/20 transition-colors">
          <.icon name={@project.icon} class="size-5" />
        </div>
        <div class="min-w-0">
          <h4 class="font-bold text-base-content group-hover:text-primary transition-colors truncate">
            {@project.title}
          </h4>
          <p class="text-xs text-base-content/50">{@project.period_label}</p>
        </div>
      </div>
      <p class="text-xs text-base-content/60 mb-3 line-clamp-2">{@project.tagline}</p>
      <div class="flex flex-wrap gap-1.5 mb-3">
        <.tech_badge :for={tech <- Enum.take(@project.tech_used, 3)} label={tech} />
      </div>
      <p class={[
        "text-base-content/70 leading-relaxed",
        if(@featured?, do: "text-sm sm:text-[15px] line-clamp-4", else: "text-sm line-clamp-2")
      ]}>
        {@project.card_copy}
      </p>
    </button>
    """
  end

  defp career_project_group(assigns) do
    assigns = assign(assigns, :projects, phase_projects(assigns.phase, assigns.group.project_ids))

    ~H"""
    <section
      id={"career-group-#{@group.id}"}
      class="rounded-2xl border border-base-300 bg-base-100 p-5 sm:p-6 shadow-sm"
    >
      <div class="flex items-start gap-3 mb-4">
        <div class="flex h-10 w-10 shrink-0 items-center justify-center rounded-xl bg-primary/10 text-primary">
          <.icon name={@group.icon} class="size-5" />
        </div>
        <div class="min-w-0">
          <h4 class="font-bold text-base-content">{@group.title}</h4>
          <p class="mt-1 text-sm text-base-content/65 leading-relaxed">{@group.description}</p>
        </div>
      </div>
      <div class="space-y-3">
        <.career_project_list_item :for={project <- @projects} project={project} />
      </div>
    </section>
    """
  end

  defp career_project_list_item(assigns) do
    ~H"""
    <button
      id={"career-project-list-#{@project.id}"}
      phx-click="open_career_modal"
      phx-value-project-id={@project.id}
      class="group w-full rounded-xl border border-base-300 bg-base-200/20 p-4 text-left transition-all duration-200 hover:border-primary/30 hover:bg-primary/5"
    >
      <div class="flex items-start justify-between gap-3">
        <div class="min-w-0">
          <div class="flex items-center gap-2">
            <h5 class="font-semibold text-base-content group-hover:text-primary transition-colors">
              {@project.title}
            </h5>
            <span class="text-xs text-base-content/45">{@project.period_label}</span>
          </div>
          <p class="mt-1 text-sm text-base-content/70 leading-relaxed">{@project.tagline}</p>
        </div>
        <div class="flex h-9 w-9 shrink-0 items-center justify-center rounded-lg border border-base-300 bg-base-100 text-primary group-hover:border-primary/30">
          <.icon name="hero-arrow-right" class="size-4" />
        </div>
      </div>
      <div class="mt-3 flex flex-wrap gap-1.5">
        <.tech_badge :for={tech <- Enum.take(@project.tech_used, 3)} label={tech} />
      </div>
    </button>
    """
  end

  defp tech_badge(assigns) do
    ~H"""
    <span class={[
      "inline-flex items-center rounded-full bg-primary/10 px-2.5 py-0.5 text-xs font-medium text-primary",
      tech_badge_modifier_classes(@label)
    ]}>
      {@label}
    </span>
    """
  end

  defp career_phase_badge_modifier_classes(label) do
    cond do
      label in ["Erlang/OTP", "Elixir", "Phoenix LiveView", "Ash Framework"] ->
        "skill-badge-primary"

      label in [
        "Cassandra",
        "Elasticsearch",
        "Elasticsearch/OpenSearch",
        "PostgreSQL",
        "RabbitMQ",
        "Distributed Systems",
        "Infrastructure Reliability",
        "Platform Ownership",
        "Leadership",
        "Technical Leadership"
      ] ->
        "skill-badge-subtle"

      true ->
        "bg-base-200 text-base-content/60"
    end
  end

  defp career_portfolio_modal(assigns) do
    phase = find_career_phase(assigns.phases, assigns.selected_project_id)
    project = find_career_project(assigns.phases, assigns.selected_project_id)
    assigns = assign(assigns, selected_phase: phase, selected_project: project)

    ~H"""
    <div
      id="career-portfolio-modal"
      class="fixed inset-0 z-50 overflow-y-auto"
      phx-window-keydown="close_career_modal"
      phx-key="Escape"
      phx-hook="LockBodyScroll"
    >
      <div class="fixed inset-0 bg-black/60 backdrop-blur-sm" phx-click="close_career_modal"></div>
      <div class="relative flex min-h-full items-start justify-center p-4 sm:p-6 lg:p-8">
        <div class="relative w-full max-w-4xl my-8 rounded-2xl border border-base-300 bg-base-100 shadow-2xl">
          <%!-- Header --%>
          <div class="sticky top-0 z-10 flex items-center justify-between gap-4 rounded-t-2xl border-b border-base-300 bg-base-100 px-6 py-4">
            <div class="flex items-center gap-3 min-w-0">
              <button
                :if={@detail_view?}
                phx-click="back_career_overview"
                class="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg hover:bg-base-200 transition-colors"
                aria-label="Back to overview"
              >
                <.icon name="hero-arrow-left" class="size-4" />
              </button>
              <div class="min-w-0">
                <h3 class="font-bold text-base-content truncate">
                  <%= if @detail_view? do %>
                    {@selected_project.title}
                  <% else %>
                    {@selected_phase.title}
                  <% end %>
                </h3>
                <p :if={!@detail_view?} class="text-xs text-base-content/50">
                  Select a project to explore
                </p>
              </div>
            </div>
            <button
              phx-click="close_career_modal"
              class="flex h-8 w-8 shrink-0 items-center justify-center rounded-lg hover:bg-base-200 transition-colors"
              aria-label="Close modal"
            >
              <.icon name="hero-x-mark" class="size-5" />
            </button>
          </div>

          <%!-- Body --%>
          <div class="p-6 max-h-[70vh] overflow-y-auto">
            <%= if @detail_view? && @selected_project do %>
              <.career_project_detail project={@selected_project} />
            <% else %>
              <div class="space-y-0">
                <%= for {project, idx} <- Enum.with_index(@selected_phase.projects) do %>
                  <.career_timeline_item
                    project={project}
                    selected?={project.id == @selected_project_id}
                    last?={idx == length(@selected_phase.projects) - 1}
                  />
                <% end %>
              </div>
            <% end %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  defp career_timeline_item(assigns) do
    ~H"""
    <div class="flex gap-4">
      <%!-- Timeline line + dot --%>
      <div class="flex flex-col items-center">
        <div class={[
          "flex h-8 w-8 shrink-0 items-center justify-center rounded-full border-2 transition-colors",
          if(@selected?,
            do: "border-primary bg-primary text-white",
            else: "border-base-300 bg-base-100 text-base-content/40"
          )
        ]}>
          <.icon name={@project.icon} class="size-4" />
        </div>
        <div :if={!@last?} class="w-0.5 flex-1 bg-base-300 my-1"></div>
      </div>

      <%!-- Content --%>
      <div
        class={[
          "flex-1 rounded-xl border p-4 mb-2 transition-all duration-200 cursor-pointer",
          if(@selected?,
            do: "border-primary/30 bg-primary/5 shadow-sm",
            else: "border-transparent hover:border-base-300 hover:bg-base-200/30"
          )
        ]}
        phx-click="select_career_project"
        phx-value-project-id={@project.id}
        role="button"
        tabindex="0"
      >
        <div class="flex items-center justify-between gap-2 mb-1">
          <h4 class={[
            "font-bold transition-colors",
            if(@selected?, do: "text-primary", else: "text-base-content")
          ]}>
            {@project.title}
          </h4>
          <span class="text-xs text-base-content/50 shrink-0">{@project.period_label}</span>
        </div>
        <p class="text-sm text-base-content/70 mb-2">{@project.tagline}</p>
        <div class="flex flex-wrap gap-1.5 mb-2">
          <.tech_badge :for={tech <- Enum.take(@project.tech_used, 4)} label={tech} />
        </div>
        <%= if @selected? do %>
          <p class="text-sm text-base-content/80 leading-relaxed mt-3 mb-3">{@project.summary}</p>
          <button
            phx-click="view_career_detail"
            class="inline-flex items-center gap-1.5 text-sm font-medium text-primary hover:text-primary/80 transition-colors"
          >
            View full details <.icon name="hero-arrow-right" class="size-4" />
          </button>
        <% end %>
      </div>
    </div>
    """
  end

  defp career_project_detail(assigns) do
    ~H"""
    <div class="space-y-8">
      <%!-- Overview --%>
      <div>
        <h4 class="text-sm font-bold text-primary uppercase tracking-wide mb-3">Overview</h4>
        <p class="text-sm text-base-content/80 leading-relaxed">{@project.summary}</p>
      </div>

      <%!-- Tech Used --%>
      <div>
        <h4 class="text-sm font-bold text-primary uppercase tracking-wide mb-3">Tech Used</h4>
        <div class="flex flex-wrap gap-2">
          <.tech_badge :for={tech <- @project.tech_used} label={tech} />
        </div>
      </div>

      <%!-- Architecture (Phase 2) or How I Designed It (Phase 1) --%>
      <div :if={Map.get(@project, :architecture) || Map.get(@project, :design)}>
        <h4 class="text-sm font-bold text-primary uppercase tracking-wide mb-3">
          {if Map.get(@project, :architecture), do: "Architecture", else: "How I Designed It"}
        </h4>
        <ul class="space-y-2">
          <li
            :for={item <- Map.get(@project, :architecture) || Map.get(@project, :design, [])}
            class="flex items-start gap-2.5 text-sm text-base-content/80 leading-relaxed"
          >
            <.icon name="hero-check-circle" class="size-4 text-primary shrink-0 mt-0.5" />
            <span>{item}</span>
          </li>
        </ul>
      </div>

      <%!-- Responsibilities --%>
      <div :if={Map.get(@project, :responsibilities)}>
        <h4 class="text-sm font-bold text-primary uppercase tracking-wide mb-3">Responsibilities</h4>
        <ul class="space-y-2">
          <li
            :for={item <- Map.get(@project, :responsibilities, [])}
            class="flex items-start gap-2.5 text-sm text-base-content/80 leading-relaxed"
          >
            <.icon name="hero-chevron-right" class="size-4 text-primary shrink-0 mt-0.5" />
            <span>{item}</span>
          </li>
        </ul>
      </div>

      <%!-- Scale --%>
      <div :if={Map.get(@project, :scale)}>
        <h4 class="text-sm font-bold text-primary uppercase tracking-wide mb-3">Scale</h4>
        <ul class="space-y-2">
          <li
            :for={item <- Map.get(@project, :scale, [])}
            class="flex items-start gap-2.5 text-sm text-base-content/80 leading-relaxed"
          >
            <.icon name="hero-arrow-trending-up" class="size-4 text-success shrink-0 mt-0.5" />
            <span>{item}</span>
          </li>
        </ul>
      </div>

      <%!-- Challenges Encountered --%>
      <div :if={Map.get(@project, :challenges)}>
        <h4 class="text-sm font-bold text-primary uppercase tracking-wide mb-3">
          Challenges Encountered
        </h4>
        <ul class="space-y-2">
          <li
            :for={item <- Map.get(@project, :challenges, [])}
            class="flex items-start gap-2.5 text-sm text-base-content/80 leading-relaxed"
          >
            <.icon name="hero-exclamation-triangle" class="size-4 text-amber-500 shrink-0 mt-0.5" />
            <span>{item}</span>
          </li>
        </ul>
      </div>

      <%!-- Subsystems --%>
      <div :if={Map.get(@project, :subsystems)}>
        <h4 class="text-sm font-bold text-primary uppercase tracking-wide mb-3">Subsystems</h4>
        <div class="flex flex-wrap gap-2">
          <span
            :for={item <- Map.get(@project, :subsystems, [])}
            class="inline-flex items-center rounded-lg bg-base-200 px-3 py-1.5 text-xs font-medium text-base-content/70"
          >
            {item}
          </span>
        </div>
      </div>

      <%!-- Time to Production --%>
      <div :if={Map.get(@project, :time_to_production)}>
        <h4 class="text-sm font-bold text-primary uppercase tracking-wide mb-3">
          Time to Production
        </h4>
        <p class="text-sm text-base-content/80">{Map.get(@project, :time_to_production)}</p>
      </div>

      <%!-- Post-Production Lessons --%>
      <div :if={Map.get(@project, :post_production_issues)}>
        <h4 class="text-sm font-bold text-primary uppercase tracking-wide mb-3">
          Post-Production Lessons
        </h4>
        <ul class="space-y-2">
          <li
            :for={item <- Map.get(@project, :post_production_issues, [])}
            class="flex items-start gap-2.5 text-sm text-base-content/80 leading-relaxed"
          >
            <.icon name="hero-light-bulb" class="size-4 text-primary shrink-0 mt-0.5" />
            <span>{item}</span>
          </li>
        </ul>
      </div>

      <%!-- Installation & Deployment --%>
      <div :if={Map.get(@project, :installation_or_deployment)}>
        <h4 class="text-sm font-bold text-primary uppercase tracking-wide mb-3">
          Installation & Deployment
        </h4>
        <ul class="space-y-2">
          <li
            :for={item <- Map.get(@project, :installation_or_deployment, [])}
            class="flex items-start gap-2.5 text-sm text-base-content/80 leading-relaxed"
          >
            <.icon name="hero-rocket-launch" class="size-4 text-primary shrink-0 mt-0.5" />
            <span>{item}</span>
          </li>
        </ul>
      </div>

      <%!-- Business Impact --%>
      <div :if={Map.get(@project, :business_impact)}>
        <h4 class="text-sm font-bold text-primary uppercase tracking-wide mb-3">Business Impact</h4>
        <ul class="space-y-2">
          <li
            :for={item <- Map.get(@project, :business_impact, [])}
            class="flex items-start gap-2.5 text-sm text-base-content/80 leading-relaxed"
          >
            <.icon name="hero-arrow-trending-up" class="size-4 text-success shrink-0 mt-0.5" />
            <span>{item}</span>
          </li>
        </ul>
      </div>
    </div>
    """
  end

  # ---------------------------------------------------------------------------
  # Career Portfolio Data
  # ---------------------------------------------------------------------------

  defp phase_projects(phase, project_ids) do
    Enum.map(project_ids, fn project_id ->
      Enum.find(phase.projects, &(&1.id == project_id))
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp find_career_project(phases, project_id) do
    Enum.find_value(phases, fn phase ->
      Enum.find(phase.projects, &(&1.id == project_id))
    end)
  end

  defp find_career_phase(phases, project_id) do
    Enum.find(phases, fn phase ->
      Enum.any?(phase.projects, &(&1.id == project_id))
    end)
  end

  defp career_portfolio_phase_one do
    %{
      id: "phase-1",
      title: "Data Verification & Email Infrastructure Foundations",
      card_title: "MTA & Verification Systems",
      card_icon: "hero-signal",
      card_era: "2014-2018 — Early Career",
      card_summary:
        "Built distributed Erlang systems powering large-scale email verification and sending infrastructure, including DNS/SMTP services, operational tooling, and backend automation for high-volume deliverability systems.",
      card_badges: [
        "Erlang/OTP",
        "PostgreSQL",
        "RabbitMQ",
        "Distributed Systems",
        "Infrastructure Reliability",
        "Online Advertising",
        "Email Deliverability",
        "REST APIs",
        "Web Protocols",
        "DNS",
        "SMTP",
        "HTTP/HTTPS",
        "Email Deliverability",
        "IP Reputation Management",
        "Infrastructure Team Leadership"
      ],
      card_bullets: [
        "Designed and built custom authoritative DNS servers and proxy infrastructure in Erlang",
        "Developed distributed monitoring, IP provisioning, and fleet management systems",
        "Built customer-facing utility software and internal operational control systems",
        "Established deep BEAM/infrastructure/systems-thinking foundations"
      ],
      overview:
        "Building customer-facing tooling, custom DNS services, distributed proxy infrastructure, monitoring systems, and operational automation for large-scale email verification and sending infrastructure.",
      projects: [
        %{
          id: "csv-repair",
          title: "CSV Repair",
          tagline:
            "Cross-platform CSV repair and normalization utility for massive data verification files",
          period_label: "Early Infrastructure",
          phase: 1,
          icon: "hero-document-text",
          card_copy:
            "Built a cross-platform CSV repair tool in C++/Qt that streamed huge malformed files, repaired rows where possible, and reduced customer costs before data verification.",
          summary:
            "A customer-facing desktop utility built in C++ and Qt to repair malformed CSV files before upload to a data verification platform. It fixed broken quoting, invalid rows, encoding-related failures, split oversized files, and reduced customer charges by removing bad rows before verification.",
          tech_used: [
            "C++",
            "Qt",
            "Desktop UI",
            "Custom CSV Parsing",
            "Multithreaded Worker Pools",
            "Binary File IO"
          ],
          design: [
            "Built as a local streaming pipeline rather than loading files fully into memory",
            "Used incremental row parsing with resume offsets",
            "Implemented a custom CSV parser that understood multiline quoted fields",
            "Added passive mode for automatic discards and active mode for manual correction",
            "Designed progress tracking and completion summaries for usability"
          ],
          challenges: [
            "Malformed CSV quoting",
            "Unicode / UTF-8 edge cases",
            "Large file performance",
            "Memory management and leak debugging",
            "Files ranging from 1 GB to multi-terabyte scale"
          ],
          subsystems: [
            "Row streaming parser",
            "CSV repair engine",
            "Active/passive correction workflow",
            "Discard file output",
            "Progress tracking",
            "Version detection / upgrade prompt",
            "Portable cross-platform distribution"
          ],
          time_to_production: "~6 months",
          post_production_issues: [
            "Encoding edge cases remained one of the hardest real-world problems",
            "Some malformed rows were unsalvageable and had to be safely discarded",
            "Memory leaks had to be hunted down through debugging and algorithm refinement"
          ],
          installation_or_deployment: [
            "Distributed as portable builds for Windows, Mac, and Linux",
            "Downloadable from the company site",
            "Mac version required signed binaries"
          ],
          business_impact: [
            "Used by thousands of customers",
            "Reduced bad row charges",
            "Reduced ingestion failures",
            "Still in use today"
          ],
          timeline_order: 1
        },
        %{
          id: "infrastructure-dns",
          title: "Infrastructure DNS",
          tagline:
            "Custom authoritative DNS platform for routing traffic across email verification infrastructure",
          period_label: "Infrastructure Scaling",
          phase: 1,
          icon: "hero-globe-alt",
          card_copy:
            "Built an Erlang authoritative DNS server that dynamically rerouted infrastructure based on MTA-detected health, protecting IP reputation across a large server fleet.",
          summary:
            "A full authoritative DNS server written in Erlang to serve infrastructure domains and dynamically redirect traffic based on infrastructure health. It supported multiple DNS record types, reverse DNS controls, runtime updates, query throttling, and large backend pools.",
          tech_used: [
            "Erlang/OTP",
            "UDP/TCP DNS",
            "Worker Pools",
            "RabbitMQ",
            "CIDR Filtering",
            "Flat-file Persistence"
          ],
          design: [
            "Separated control plane and data plane responsibilities",
            "Core MTA detected unhealthy infrastructure and pushed DNS updates",
            "Stayed focused on fast authoritative query serving",
            "Built listener processes, protocol handlers, rDNS filtering, and throttling"
          ],
          challenges: [
            "Provider blocking",
            "SMTP failures at VPS/provider level",
            "Reputation management",
            "Keeping DNS updates correct under live traffic",
            "Query flood / abuse protection"
          ],
          subsystems: [
            "Authoritative DNS packet parsing / serialization",
            "UDP/TCP listeners",
            "Query throttling",
            "rDNS firewall",
            "Runtime update flow",
            "Domain rotation support"
          ],
          time_to_production: "Built and evolved during early infrastructure scaling",
          post_production_issues: [
            "Records needed to be updated dynamically when servers were marked unhealthy",
            "Domain rotation experiments were used to reduce blacklist and overuse risk"
          ],
          installation_or_deployment: [
            "Deployed as independent Erlang DNS nodes",
            "Served 50–500 backend servers depending on operational scale"
          ],
          business_impact: [
            "Improved availability and protected infrastructure",
            "Supported performance and reputation goals",
            "Handled hundreds to thousands of DNS queries per second at peak"
          ],
          timeline_order: 2
        },
        %{
          id: "edge-proxy",
          title: "Edge Proxy",
          tagline:
            "Distributed Erlang proxy node for SMTP, HTTP/HTTPS, and DNS on disposable global VPS infrastructure",
          period_label: "Infrastructure Scaling",
          phase: 1,
          icon: "hero-server-stack",
          card_copy:
            "Built a distributed Erlang proxy platform on disposable VPS nodes worldwide to shield core infrastructure while handling high-concurrency SMTP, HTTP/HTTPS, and DNS traffic.",
          summary:
            "A multi-protocol proxy system deployed on VPS nodes around the world so disposable infrastructure could act publicly while protecting core IP ranges. It proxied SMTP, HTTP/HTTPS, and DNS traffic and dynamically pulled configuration from the core MTA.",
          tech_used: [
            "Erlang/OTP",
            "Ranch",
            "Cowboy",
            "Mnesia",
            "Supervisor Trees",
            "Systemd"
          ],
          design: [
            "Disposable VPS nodes acted as the public-facing infrastructure layer",
            "Core MTA remained protected behind them",
            "Nodes bootstrapped by pulling config from core over HTTP",
            "Protocol-specific handlers were separated cleanly",
            "Connection-level relay design preserved performance and transparency"
          ],
          challenges: [
            "Provider response behavior changed constantly",
            "Centralizing logs for fast iteration",
            "Scaling node count when VPS supply was limited",
            "Protocol-specific edge cases in SMTP DATA handling and bind-IP routing"
          ],
          subsystems: [
            "SMTP inbound relay",
            "SMTP outbound relay",
            "HTTP/HTTPS proxying",
            "DNS support",
            "Config bootstrap / refresh FSM",
            "Firewall / IP filtering",
            "Certificate handling",
            "Status checks"
          ],
          time_to_production: "MVP in ~1 month; 2–3 more months to stable production",
          post_production_issues: [
            "Provider-side behavior drift required ongoing tuning",
            "Operational visibility mattered more than theoretical elegance",
            "Stable monitoring and config refresh were critical"
          ],
          installation_or_deployment: [
            "Initially installed by bash scripts, later converted to Ansible-based provisioning",
            "Fleet size commonly ranged from 50–500 nodes",
            "Each node could handle thousands of simultaneous connections"
          ],
          business_impact: [
            "Protected core IP ranges",
            "Scaled verification and sending operations",
            "Allowed disposable replacement of blocked nodes",
            "Still actively used today"
          ],
          timeline_order: 3
        },
        %{
          id: "infrastructure-monitoring",
          title: "Infrastructure Monitoring",
          tagline:
            "Distributed Erlang monitoring system for node health, DNS integrity, and IP/domain reputation",
          period_label: "Operational Maturity",
          phase: 1,
          icon: "hero-bell-alert",
          card_copy:
            "Built a distributed Erlang monitoring system that ran thousands of scheduled health and reputation checks across a large VPS fleet to preserve uptime and IP quality.",
          summary:
            "A master/slave Erlang monitoring system that continuously ran health and reputation checks across the proxy fleet, collected results from monitoring checks, broadcasted notifications to core systems via RabbitMQ, and alerted admins when nodes should be replaced or removed from rotation.",
          tech_used: [
            "Erlang/OTP",
            "RabbitMQ",
            "Mnesia",
            "Poolboy",
            "HTTP Workers",
            "Master/Slave Architecture"
          ],
          design: [
            "Master/slave layout",
            "Monitor lifecycle driven by infrastructure events from the MTA",
            "One monitor per active domain/target with per-check workers",
            "Slot-based scheduling with jitter to avoid thundering herd behavior",
            "Expected-value validation instead of simplistic up/down checks"
          ],
          challenges: [
            "Scaling periodic monitoring across the full fleet",
            "Balancing responsiveness with controlled concurrency",
            "Validating DNS/reputation results without noisy false positives"
          ],
          subsystems: [
            "Monitor supervisor",
            "Per-check workers",
            "AMQP config/result flow",
            "Slot scheduler",
            "HTTP, SMTP, DNS, rDNS, RBL, DBL, sender score, Google threat, version checks"
          ],
          time_to_production: "Built and evolved alongside the monitoring fleet",
          post_production_issues: [
            "Minimal instability,  stable and low-maintenance from early on",
            "Emphasis shifted toward pragmatic health signals rather than overly heavy metrics"
          ],
          installation_or_deployment: [
            "Core node plus slave nodes",
            "Monitor creation triggered automatically when proxy config changed",
            "Effective scale reached ~5,000 periodic checks across 500 nodes × ~10 check types"
          ],
          business_impact: [
            "Centralized visibility across the entire fleet",
            "Alerted admins for node replacement, IP rotation, DNS updates, and traffic pausing",
            "Foundational operational tool for infrastructure reliability"
          ],
          timeline_order: 4
        },
        %{
          id: "ip-provisioning",
          title: "IP Provisioning",
          tagline:
            "Postgres-driven IP range onboarding and DNS allocation workflow for email infrastructure growth",
          period_label: "Operational Maturity",
          phase: 1,
          icon: "hero-squares-plus",
          card_copy:
            "Automated IP range onboarding in Postgres, turning newly purchased CIDR blocks into production-ready DNS, rDNS, and delivery-node allocations.",
          summary:
            "Built Postgres-backed automation to ingest newly purchased IP ranges and fully wire them into the sending infrastructure, including IP expansion, DNS/rDNS generation, node config updates, and static allocation to delivery nodes.",
          tech_used: [
            "PostgreSQL",
            "CIDR/IP Modeling",
            "CLI Workflows",
            "Core MTA Integration"
          ],
          design: [
            "Used Postgres as the source of truth for the IP pool",
            "Represented ranges as CIDR-backed iprange records",
            "Generated individual ipresource rows for usable IPs",
            "Automated DNS, rDNS, and node config relationships",
            "Supported deterministic static assignment by delivery node"
          ],
          challenges: [
            "Sourcing high-quality IP ranges for target provider ecosystems",
            "Managing large range ingestions accurately",
            "Preventing overlap and duplicate allocations",
            "Warming new ranges safely to avoid immediate provider blocks"
          ],
          subsystems: [
            "iprange ingestion",
            "ipresource expansion",
            "Forward DNS generation",
            "rDNS mapping",
            "Config relationships for delivery nodes → edge proxies",
            "Static allocation model",
            "Warm-up / validation workflow"
          ],
          time_to_production: "Built as part of ongoing infrastructure scaling",
          post_production_issues: [
            "New ranges needed careful validation and gradual warm-up",
            "Reputation and provider acceptance mattered more than raw address count"
          ],
          installation_or_deployment: [
            "Invoked manually through CLI",
            "Edge proxy nodes later pulled resulting config from core over HTTP",
            "Typical purchases were /22 ranges split into /24 blocks"
          ],
          business_impact: [
            "Accelerated infrastructure growth",
            "Reduced manual configuration work",
            "Made large-scale IP onboarding operationally feasible"
          ],
          timeline_order: 5
        },
        %{
          id: "mx-dns",
          title: "MX DNS",
          tagline: "Specialized Erlang DNS appliance optimized for MX-focused provider workflows",
          period_label: "Operational Maturity",
          phase: 1,
          icon: "hero-signal",
          card_copy:
            "Built a focused Erlang DNS service for MX provisioning workflows, optimized for quick updates, bounded concurrency, and safer handling under UDP abuse.",
          summary:
            "A narrower, operationally simpler authoritative DNS service built specifically for MX-centric provisioning workflows where fast updates, clean NS/MX behavior, and abuse resistance mattered more than broad DNS feature coverage.",
          tech_used: [
            "Erlang/OTP",
            "Poolboy",
            "Mnesia",
            "UDP DNS",
            "Rate Limiting",
            "Worker Pools"
          ],
          design: [
            "Intentionally narrower than the infrastructure DNS",
            "Optimized for operational simplicity and quick MX updates",
            "Authoritative for configured in-zone requests",
            "Refused out-of-zone/disallowed paths",
            "Used pooled workers and in-memory persistence for fast handling"
          ],
          challenges: [
            "Keeping live DNS behavior correct during dynamic add/remove updates",
            "Staying resilient against UDP abuse and amplification-style traffic"
          ],
          subsystems: [
            "UDP listener",
            "Zone-limited authoritative responder",
            "MX/A/NS/SOA response generation",
            "Query throttling",
            "Mnesia-backed config storage",
            "Worker pool concurrency"
          ],
          time_to_production: "Built alongside evolving provider workflows",
          post_production_issues: [
            "Correctness under live config mutation was the core concern",
            "Focused tools can be better than broad platforms for specialized operational workflows"
          ],
          installation_or_deployment: [
            "Deployed as an Erlang DNS service specialized for MX/provider setup flows"
          ],
          business_impact: [
            "Simplified operational workflows for MX/rDNS provisioning",
            "Gave the team a focused DNS appliance for a specific infrastructure need"
          ],
          timeline_order: 6
        }
      ]
    }
  end

  defp career_portfolio_phase_two do
    %{
      id: "phase-2",
      title: "Affiliate Network Platform & Infrastructure Leadership",
      card_title: "Affiliate Network Platform",
      card_icon: "hero-chart-bar",
      card_era: "2018–Present — Senior Engineer & Platform Ownership",
      card_summary:
        "Long-term ownership of a revenue-critical affiliate marketing platform in Erlang/OTP, complemented by NetAdmin, the Elixir control plane I built for infrastructure lifecycle orchestration and monitoring.",
      card_badges: [
        "Erlang/OTP",
        "Elixir",
        "Phoenix LiveView",
        "Ash Framework",
        "Cassandra",
        "Elasticsearch/OpenSearch",
        "RabbitMQ",
        "PostgreSQL",
        "Apache Spark",
        "REST APIs",
        "HTTP",
        "WebSockets",
        "DNS",
        "SMTP",
        "Technical Leadership",
        "Affiliate Marketing Technology"
      ],
      card_bullets: [
        "Owned the backend architecture of a $2.5M+/month affiliate platform processing 1.5M+ events/day",
        "Built click tracking, attribution, reporting, and partner integration systems in Erlang/OTP",
        "Architected NetAdmin in Elixir/Phoenix LiveView/Ash as the internal infrastructure control plane",
        "Led UI and infrastructure engineers while staying hands-on in architecture, code, and operations"
      ],
      overview:
        "This phase is the core of my professional story: long-term ownership of a revenue-critical affiliate marketing platform, plus the Elixir control plane I built to manage infrastructure and operational workflows around it.",
      metrics: [
        %{value: "1.5M+", label: "events / day"},
        %{value: "$2.5M+", label: "monthly revenue"},
        %{value: "6-node", label: "Cassandra cluster"},
        %{value: "~25%", label: "lower infra costs"},
        %{value: "5", label: "engineers led"}
      ],
      team: %{
        description:
          "I stayed hands-on while leading engineers, owning backend architecture, and driving production operations for the affiliate platform and the systems around it.",
        members: [
          "Worked closely with the CTO on partner requirements, reporting needs, business rules, and core technology decisions",
          "Owned the long-term backend architecture for the affiliate platform and its supporting services",
          "Led up to 2 UI engineers and 3 infrastructure engineers while remaining active in system design and implementation",
          "Handled releases, production debugging, infrastructure audits, and cost strategy without stepping away from code"
        ]
      },
      featured_project_ids: ["affiliate-network-platform", "netadmin-platform"],
      project_groups: [
        %{
          id: "tracking-attribution",
          title: "Tracking, Attribution & Partner Integrations",
          description:
            "Supporting services that turned incoming traffic into attributable, reportable partner outcomes.",
          icon: "hero-arrows-right-left",
          project_ids: [
            "edge-redirect-service",
            "conversion-callback-engine",
            "tracking-domain-infra"
          ]
        },
        %{
          id: "analytics-reporting",
          title: "Analytics, Reporting & Data Infrastructure",
          description:
            "The ingestion, storage, aggregation, and reporting systems behind partner analytics and operational visibility.",
          icon: "hero-circle-stack",
          project_ids: [
            "traffic-analytics-pipeline",
            "distributed-data-platform"
          ]
        }
      ],
      projects: [
        %{
          id: "affiliate-network-platform",
          title: "Affiliate Marketing Platform",
          tagline:
            "Flagship Erlang/OTP platform for click tracking, attribution, reporting, and partner integrations",
          period_label: "Core Platform",
          phase: 2,
          icon: "hero-chart-bar",
          featured_label: "Flagship Distributed System",
          card_copy:
            "Revenue-critical Erlang/OTP system supporting $2.5M+ monthly revenue and 1.5M+ daily events across click tracking, attribution, campaign logic, reporting, and partner APIs.",
          summary:
            "The core backend platform I owned for the affiliate business. It handled click, impression, and conversion tracking; attribution; reporting; partner integrations; and the operational workflows that made the platform revenue-critical.",
          tech_used: [
            "Erlang/OTP",
            "Cassandra",
            "PostgreSQL",
            "RabbitMQ",
            "Elasticsearch/OpenSearch",
            "REST APIs",
            "Apache Spark"
          ],
          architecture: [
            "Event-driven Erlang services handled tracking, attribution, routing, and partner workflows",
            "Cassandra stored high-volume raw event data and time-series traffic history",
            "PostgreSQL supported operational workflows, reporting datasets, and financial views",
            "RabbitMQ connected ingestion, callbacks, and downstream processing services",
            "Elasticsearch/OpenSearch powered detailed partner reporting and performance analytics",
            "Spark pipelines aggregated raw event data into reporting datasets used for analytics and finance"
          ],
          responsibilities: [
            "Owned backend architecture, features, and production operations for the platform",
            "Built and maintained click, impression, and conversion tracking paths",
            "Implemented attribution, routing, campaign configuration, and payout workflows",
            "Designed partner-facing and internal REST APIs plus service integrations",
            "Owned data modeling, query tuning, and reporting paths across Cassandra and PostgreSQL"
          ],
          scale: [
            "1.5M+ events processed daily",
            "$2.5M+ monthly revenue supported by the platform",
            "6-node Cassandra production cluster",
            "Real-time partner reporting and high-volume transaction paths"
          ],
          business_impact: [
            "Served as the primary technical engine behind a long-running affiliate business",
            "Demonstrated sustained ownership of a revenue-critical distributed system on the BEAM"
          ],
          timeline_order: 1
        },
        %{
          id: "netadmin-platform",
          title: "NetAdmin",
          tagline:
            "Elixir control plane for lifecycle orchestration, monitoring, log streaming, and operational auditability",
          period_label: "Internal Tooling",
          phase: 2,
          icon: "hero-cog-6-tooth",
          featured_label: "Featured Elixir Platform",
          card_copy:
            "Phoenix + LiveView + Ash platform for provisioning, service lifecycle automation, monitoring, auditability, and cross-system operational workflows.",
          summary:
            "NetAdmin was the internal infrastructure platform I architected and built in Elixir. It started as a way to manage affiliate platform infrastructure and expanded into a control plane for MTA, verification, and other company systems.",
          tech_used: [
            "Elixir",
            "Phoenix",
            "LiveView",
            "Ash Framework",
            "PostgreSQL",
            "Ansible"
          ],
          architecture: [
            "Phoenix + LiveView UI backed by Ash resources and authorization rules",
            "PostgreSQL as the system of record for infrastructure state and operational history",
            "Ansible integration for provisioning and lifecycle automation",
            "Cross-system workflows spanning the affiliate platform, MTA, verification systems, and external platforms",
            "Real-time dashboards, operational monitoring, and log visibility for daily operations",
            "Operational auditability built into the platform rather than bolted on afterward"
          ],
          responsibilities: [
            "Resource lifecycle orchestration",
            "VPS, service, domain, and SSL management",
            "Monitoring dashboards and operational visibility",
            "Real-time log streaming and cross-system troubleshooting support",
            "Authorization modeling and auditability",
            "Automation across multiple internal platforms"
          ],
          business_impact: [
            "Centralized infrastructure operations that had previously been spread across scripts and tribal knowledge",
            "Showcases deep Elixir, Phoenix LiveView, and Ash experience in a production internal platform"
          ],
          timeline_order: 2
        },
        %{
          id: "edge-redirect-service",
          title: "Tracking Edge Service",
          tagline:
            "High-performance Erlang service handling tracking links and routing traffic based on campaign rules",
          period_label: "Edge Infrastructure",
          phase: 2,
          icon: "hero-arrows-right-left",
          card_copy:
            "Erlang edge service generating real-time redirect decisions for tracking links based on campaign routing, geo rules, and cap logic.",
          summary:
            "High-performance edge service responsible for handling affiliate tracking links and routing traffic based on campaign rules. It sat close to incoming HTTP traffic and turned campaign configuration into live redirect behavior.",
          tech_used: [
            "Erlang/OTP",
            "HTTP",
            "DNS",
            "VPS Infrastructure"
          ],
          architecture: [
            "Erlang service deployed on tracking edge nodes close to incoming traffic",
            "Tracking domains routed HTTP requests into the service",
            "Nodes pulled campaign configuration and routing rules from backend systems",
            "Redirect responses were generated in real time based on live business logic"
          ],
          responsibilities: [
            "Campaign routing",
            "Geo targeting",
            "Sub-ID tracking",
            "Redirect decision logic",
            "Campaign cap enforcement"
          ],
          timeline_order: 3
        },
        %{
          id: "traffic-analytics-pipeline",
          title: "Traffic Logging & Analytics Pipeline",
          tagline:
            "Distributed event pipeline for ingesting click, impression, and conversion events powering analytics and reporting",
          period_label: "Data & Analytics",
          phase: 2,
          icon: "hero-circle-stack",
          card_copy:
            "Distributed ingestion and indexing pipeline feeding partner analytics, reporting, and downstream aggregation from raw traffic events.",
          summary:
            "Distributed event pipeline responsible for ingesting click, impression, and conversion events and turning them into the analytics and reports used throughout the affiliate platform.",
          tech_used: [
            "Cassandra",
            "RabbitMQ",
            "Elasticsearch/OpenSearch",
            "Apache Spark"
          ],
          architecture: [
            "RabbitMQ buffered and distributed event work between services",
            "Cassandra stored high-volume event data for long-term analysis",
            "Search and analytics infrastructure powered detailed reporting views",
            "Spark aggregation jobs transformed raw data into reporting-friendly datasets"
          ],
          responsibilities: [
            "Event ingestion",
            "Traffic logging",
            "Analytics indexing",
            "Report aggregation",
            "Export dataset generation"
          ],
          scale: [
            "1.5M+ daily events across click, impression, and conversion paths",
            "High-volume analytics and reporting workloads running continuously"
          ],
          timeline_order: 4
        },
        %{
          id: "conversion-callback-engine",
          title: "Conversion Callback Engine",
          tagline: "Reliable delivery system for advertiser and affiliate conversion callbacks",
          period_label: "Core Platform",
          phase: 2,
          icon: "hero-paper-airplane",
          card_copy:
            "Reliable server-to-server callback delivery system with retry logic, macro substitution, delivery tracking, and failure handling.",
          summary:
            "Reliable delivery system for advertiser and affiliate conversion callbacks. It handled server-to-server notifications, retry behavior, macro substitution, and tracking around partner delivery failures.",
          tech_used: [
            "RabbitMQ",
            "Erlang Worker Pools",
            "HTTP Callback Integrations"
          ],
          responsibilities: [
            "Server-to-server conversion notifications",
            "Retry handling",
            "Macro substitution",
            "Delivery tracking",
            "Failure handling"
          ],
          timeline_order: 5
        },
        %{
          id: "tracking-domain-infra",
          title: "Tracking Domain Infrastructure",
          tagline:
            "Domain, SSL, and routing infrastructure behind tracking links and redirect services",
          period_label: "Infrastructure",
          phase: 2,
          icon: "hero-globe-alt",
          card_copy:
            "Managed the lifecycle of tracking domains, SSL certificates, routing configuration, and domain rotation experiments.",
          summary:
            "Infrastructure responsible for managing tracking domains and routing configuration. It handled the DNS and SSL layer that allowed tracking services to operate cleanly and evolve over time.",
          tech_used: [
            "DNS",
            "HTTP",
            "SSL/TLS + letsencrypt",
            "Domain Management"
          ],
          responsibilities: [
            "Tracking domain management",
            "SSL certificate management",
            "DNS routing configuration",
            "Domain rotation experiments to reduce blacklist risk"
          ],
          timeline_order: 6
        },
        %{
          id: "distributed-data-platform",
          title: "Distributed Data Platform",
          tagline:
            "Large-scale data storage and analytics infrastructure supporting event ingestion and reporting",
          period_label: "Data Infrastructure",
          phase: 2,
          icon: "hero-server-stack",
          card_copy:
            "Operated the core data layer behind the platform, including Cassandra, analytics infrastructure, Spark jobs, and RabbitMQ pipelines.",
          summary:
            "Large-scale data storage and analytics infrastructure supporting event ingestion and reporting across the affiliate platform.",
          tech_used: [
            "Cassandra",
            "Elasticsearch/OpenSearch",
            "Apache Spark (Scala)",
            "RabbitMQ"
          ],
          architecture: [
            "Cassandra cluster (6 nodes) for high-throughput event storage",
            "Search and analytics infrastructure for detailed reporting",
            "Spark aggregation jobs for batch processing and reporting dataset generation",
            "RabbitMQ-fed services for near-real-time downstream processing"
          ],
          responsibilities: [
            "High-throughput event ingestion",
            "Long-term traffic storage",
            "Analytics indexing",
            "Reporting aggregation"
          ],
          scale: [
            "6-node Cassandra production cluster",
            "Large reporting and analytics workloads across raw and aggregated event data"
          ],
          timeline_order: 7
        }
      ]
    }
  end

  defp tech_badge_modifier_classes(label) do
    cond do
      label in ["Elixir", "Erlang/OTP", "Phoenix", "LiveView", "Ash", "Ash Framework"] ->
        "skill-badge skill-badge-primary"

      label in [
        "Cassandra",
        "PostgreSQL",
        "Postgres",
        "RabbitMQ",
        "Elasticsearch",
        "Elasticsearch/OpenSearch",
        "OpenSearch",
        "Apache Spark",
        "AWS",
        "Linux",
        "Ansible",
        "Ecto",
        "Swoosh",
        "Fly.io"
      ] ->
        "skill-badge skill-badge-subtle"

      true ->
        nil
    end
  end
end
