defmodule RevstackWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use RevstackWeb, :html

  # Embed all files in layouts/* within this module.
  # The default root.html.heex file contains the HTML
  # skeleton of your application, namely HTML headers
  # and other static content.
  embed_templates("layouts/*")

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr(:flash, :map, required: true, doc: "the map of flash messages")

  attr(:current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"
  )

  attr(:current_user, :map,
    default: nil,
    doc: "the currently signed-in user"
  )

  slot(:inner_block, required: true)

  def app(assigns) do
    ~H"""
    <header
      id="top"
      class="sticky top-0 z-40 border-b border-base-300 bg-base-100/80 backdrop-blur-lg"
    >
      <nav class="mx-auto flex max-w-6xl items-center justify-between px-4 py-3 sm:px-6 lg:px-8">
        <div class="flex items-center gap-1">
          <%!-- <a
            href="/"
            class="text-xl font-extrabold tracking-tight text-primary hover:opacity-80 transition-opacity"
          >
            RevenueLink Technologies
          </a> --%>
          <a
            id="nav-brand"
            href="#top"
            data-scroll-top="true"
            class="text-xl font-extrabold tracking-tight text-primary hover:opacity-80 transition-opacity"
          >
            Kyle Neal | Distributed Systems Engineer
          </a>
        </div>

        <%!-- Desktop Nav --%>
        <div class="hidden md:flex items-center gap-1">
          <.link
            id="nav-home"
            data-scroll-top="true"
            navigate="/"
            phx-click-capture={JS.dispatch("phx:scroll-top")}
            class="px-3 py-2 text-sm font-medium text-base-content/70 hover:text-base-content rounded-lg hover:bg-base-200 transition-colors"
          >
            Home
          </.link>
          <%!-- <.link
            navigate="/about"
            class="px-3 py-2 text-sm font-medium text-base-content/70 hover:text-base-content rounded-lg hover:bg-base-200 transition-colors"
          >
            About
          </.link>
          <.link
            navigate="/services"
            class="px-3 py-2 text-sm font-medium text-base-content/70 hover:text-base-content rounded-lg hover:bg-base-200 transition-colors"
          >
            Services
          </.link> --%>
          <.link
            navigate="/contact"
            class="px-3 py-2 text-sm font-medium text-base-content/70 hover:text-base-content rounded-lg hover:bg-base-200 transition-colors"
          >
            Contact
          </.link>
          <%!-- <.link
            navigate="/whoami"
            class="px-3 py-2 text-sm font-medium text-base-content/70 hover:text-base-content rounded-lg hover:bg-base-200 transition-colors"
          >
            Kyle
          </.link>
           <.link
            navigate="/estimate"
            class="ml-2 btn btn-primary btn-sm shadow-sm hover:shadow-md transition-all"
          >
            Get an Estimate
          </.link> --%>
          <%= if @current_user do %>
            <details class="dropdown dropdown-end ml-2">
              <summary class="btn btn-ghost h-auto min-h-0 gap-3 rounded-xl px-3 py-2 normal-case hover:bg-base-200">
                <div class="text-right leading-tight">
                  <p class="text-[11px] font-semibold uppercase tracking-[0.18em] text-base-content/45">
                    Signed In
                  </p>
                  <p class="text-sm font-medium text-base-content">{@current_user.email}</p>
                </div>
                <.icon name="hero-chevron-down" class="size-4 text-base-content/55" />
              </summary>
              <ul class="menu dropdown-content z-50 mt-3 w-56 rounded-2xl border border-base-300 bg-base-100 p-2 shadow-xl">
                <li>
                  <.link navigate="/admin" class="rounded-xl">
                    <.icon name="hero-squares-2x2" class="size-4" /> Admin Dashboard
                  </.link>
                </li>
                <li>
                  <.link href={~p"/sign-out"} method="get" class="rounded-xl text-error">
                    <.icon name="hero-arrow-left-on-rectangle" class="size-4" /> Sign out
                  </.link>
                </li>
              </ul>
            </details>
          <% end %>

          <div class={[@current_user && "ml-1", !@current_user && "ml-2"]}>
            <.theme_toggle />
          </div>
        </div>

        <%!-- Mobile menu button --%>
        <div class="flex items-center gap-2 md:hidden">
          <%= if @current_user do %>
            <details class="dropdown dropdown-end">
              <summary class="btn btn-ghost btn-sm h-auto min-h-0 gap-2 rounded-xl px-3 py-2 normal-case">
                <span class="max-w-28 truncate text-sm font-medium text-base-content">
                  {@current_user.email}
                </span>
                <.icon name="hero-chevron-down" class="size-4 text-base-content/55" />
              </summary>
              <ul class="menu dropdown-content z-50 mt-3 w-56 rounded-2xl border border-base-300 bg-base-100 p-2 shadow-xl">
                <li>
                  <.link navigate="/admin" class="rounded-xl">
                    <.icon name="hero-squares-2x2" class="size-4" /> Admin Dashboard
                  </.link>
                </li>
                <li>
                  <.link href={~p"/sign-out"} method="get" class="rounded-xl text-error">
                    <.icon name="hero-arrow-left-on-rectangle" class="size-4" /> Sign out
                  </.link>
                </li>
              </ul>
            </details>
          <% end %>

          <.theme_toggle />
          <label for="mobile-menu-toggle" class="btn btn-ghost btn-sm btn-square cursor-pointer">
            <.icon name="hero-bars-3" class="size-5" />
          </label>
        </div>
      </nav>

      <%!-- Mobile dropdown menu --%>
      <input type="checkbox" id="mobile-menu-toggle" class="peer hidden" />
      <div class="hidden peer-checked:block md:hidden border-t border-base-300 bg-base-100 px-4 pb-4 pt-2">
        <div class="flex flex-col gap-1">
          <.link
            id="mobile-nav-home"
            data-scroll-top="true"
            navigate="/"
            phx-click-capture={JS.dispatch("phx:scroll-top")}
            class="px-3 py-2 text-sm font-medium text-base-content/70 hover:text-base-content rounded-lg hover:bg-base-200 transition-colors"
          >
            Home
          </.link>
          <%!-- <.link
            navigate="/about"
            class="px-3 py-2 text-sm font-medium text-base-content/70 hover:text-base-content rounded-lg hover:bg-base-200 transition-colors"
          >
            About
          </.link>
          <.link
            navigate="/services"
            class="px-3 py-2 text-sm font-medium text-base-content/70 hover:text-base-content rounded-lg hover:bg-base-200 transition-colors"
          >
            Services
          </.link> --%>
          <.link
            navigate="/contact"
            class="px-3 py-2 text-sm font-medium text-base-content/70 hover:text-base-content rounded-lg hover:bg-base-200 transition-colors"
          >
            Contact
          </.link>
          <.link
            navigate="/whoami"
            class="px-3 py-2 text-sm font-medium text-base-content/70 hover:text-base-content rounded-lg hover:bg-base-200 transition-colors"
          >
            Kyle
          </.link>
          <.link navigate="/estimate" class="btn btn-primary btn-sm mt-2 shadow-sm">
            Get an Estimate
          </.link>
        </div>
      </div>
    </header>

    <main class="mx-auto max-w-6xl px-4 py-8 sm:px-6 lg:px-8">
      {render_slot(@inner_block)}
    </main>

    <footer class="border-t border-base-300 bg-base-200/50 mt-16">
      <div class="mx-auto max-w-6xl px-4 py-12 sm:px-6 lg:px-8">
        <div class="flex flex-col sm:flex-row items-center justify-between gap-6">
          <div class="text-center sm:text-left">
            <p class="text-sm font-semibold text-base-content">Kyle Neal</p>
            <p class="text-xs text-base-content/50 mt-1">RevenueLink Technologies LLC</p>
          </div>
          <div class="flex items-center gap-4 text-sm text-base-content/60">
            <.link navigate="/privacy" class="hover:text-base-content transition-colors">
              Privacy
            </.link>
            <span class="text-base-content/20">|</span>
            <a
              href="https://github.com/kyle-neal"
              target="_blank"
              rel="noopener noreferrer"
              class="hover:text-base-content transition-colors"
            >
              GitHub
            </a>
            <span class="text-base-content/20">|</span>
            <a
              href="https://www.linkedin.com/in/kyle-n-0bbb52a1/"
              target="_blank"
              rel="noopener noreferrer"
              class="hover:text-base-content transition-colors"
            >
              LinkedIn
            </a>
            <span class="text-base-content/20">|</span>
            <a
              href="mailto:nealkyle5@gmail.com"
              class="hover:text-base-content transition-colors"
            >
              nealkyle5@gmail.com
            </a>
          </div>
        </div>
        <div class="mt-6 text-center text-xs text-base-content/40">
          &copy; {DateTime.utc_now().year} RevenueLink Technologies LLC. All rights reserved.
        </div>
      </div>
    </footer>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr(:flash, :map, required: true, doc: "the map of flash messages")
  attr(:id, :string, default: "flash-group", doc: "the optional id of flash container")

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-1/3 h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-1/3 [[data-theme=dark]_&]:left-2/3 transition-[left]" />

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
      >
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button
        class="flex p-2 cursor-pointer w-1/3"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
      >
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end
end
