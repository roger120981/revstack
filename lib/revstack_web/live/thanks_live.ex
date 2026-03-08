defmodule RevstackWeb.ThanksLive do
  use RevstackWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Thank You — Revstack")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={assigns[:current_user]}>
      <section class="py-24 sm:py-36">
        <div class="mx-auto max-w-2xl text-center">
          <div class="flex h-20 w-20 items-center justify-center rounded-full bg-success/10 text-success mx-auto mb-8">
            <.icon name="hero-check-circle" class="size-12" />
          </div>
          <h1 class="text-4xl sm:text-5xl font-extrabold tracking-tight text-base-content">
            Thank You!
          </h1>
          <p class="mt-6 text-lg text-base-content/70 leading-relaxed">
            Your message has been received. I'll review it and get back to you as soon as possible.
          </p>
          <div class="mt-10 flex flex-col sm:flex-row items-center justify-center gap-4">
            <.link
              navigate={~p"/"}
              class="btn btn-primary btn-lg gap-2 shadow-lg hover:shadow-xl transition-all duration-300 hover:-translate-y-0.5"
            >
              <.icon name="hero-home" class="size-5" /> Back to Home
            </.link>
            <%!-- <.link
              navigate={~p"/services"}
              class="btn btn-outline btn-lg gap-2 transition-all duration-300 hover:-translate-y-0.5"
            >
              <.icon name="hero-briefcase" class="size-5" /> View Services
            </.link> --%>
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end
end
