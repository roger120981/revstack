defmodule RevstackWeb.AdminLayouts do
  @moduledoc """
  Admin panel layout with a RevenueLink-inspired admin palette.
  Inspired by the admin_ui_template.html reference design.
  """
  use RevstackWeb, :html

  attr :flash, :map, required: true
  attr :current_user, :map, required: true
  attr :current_path, :string, default: "/admin"
  slot :inner_block, required: true
  slot :page_title
  slot :page_actions

  def admin(assigns) do
    assigns =
      assigns
      |> assign(:topbar_user_label, topbar_user_label(assigns.current_user))
      |> assign(:topbar_user_initial, topbar_user_initial(assigns.current_user))
      |> assign(:utc_time, format_utc_time(DateTime.utc_now()))

    ~H"""
    <%!-- Mobile sidebar overlay --%>
    <div
      :if={false}
      id="mobile-sidebar-backdrop"
      class="fixed inset-0 z-50 bg-gray-900/80 lg:hidden"
      phx-click={hide_sidebar()}
    >
    </div>

    <%!-- Mobile sidebar --%>
    <div
      id="mobile-sidebar"
      class="fixed inset-y-0 left-0 z-50 w-72 transform -translate-x-full transition-transform duration-300 ease-in-out lg:hidden"
      phx-hook=".AdminSidebar"
    >
      <div class="relative flex h-full grow flex-col gap-y-5 overflow-y-auto bg-gradient-to-b from-[#0f4a92] via-[#17376a] to-[#101f44] px-6 pb-4 ring-1 ring-white/10 dark:from-[#07172b] dark:via-[#0a2038] dark:to-[#0c1730] dark:ring-sky-400/10">
        <div class="flex h-16 shrink-0 items-center justify-between">
          <.brand_logo container_id="mobile-brand-logo" image_id="mobile-brand-logo-image" />
          <button
            type="button"
            class="-m-2.5 rounded-md p-2.5 text-sky-100/80 transition-colors hover:bg-white/10 hover:text-white lg:hidden"
            phx-click={hide_sidebar()}
          >
            <span class="sr-only">Close sidebar</span>
            <.icon name="hero-x-mark" class="size-6" />
          </button>
        </div>
        <.sidebar_nav current_path={@current_path} />
      </div>
    </div>

    <%!-- Desktop sidebar --%>
    <div class="hidden lg:fixed lg:inset-y-0 lg:z-50 lg:flex lg:w-72 lg:flex-col">
      <div class="relative flex grow flex-col gap-y-5 overflow-y-auto bg-gradient-to-b from-[#0f4a92] via-[#17376a] to-[#101f44] px-6 pb-4 after:pointer-events-none after:absolute after:inset-y-0 after:right-0 after:w-px after:bg-white/10 dark:from-[#07172b] dark:via-[#0a2038] dark:to-[#0c1730] dark:ring-1 dark:ring-inset dark:ring-sky-400/10 dark:after:bg-sky-400/10">
        <div class="flex h-16 shrink-0 items-center">
          <.brand_logo container_id="desktop-brand-logo" image_id="desktop-brand-logo-image" />
        </div>
        <.sidebar_nav current_path={@current_path} />
      </div>
    </div>

    <%!-- Main content area --%>
    <div class="lg:pl-72">
      <%!-- Top bar --%>
      <div class="sticky top-0 z-40 flex h-16 shrink-0 items-center gap-x-4 border-b border-sky-100 bg-white/95 px-4 shadow-[0_1px_0_rgba(10,40,80,0.06)] backdrop-blur sm:gap-x-6 sm:px-6 lg:px-8 dark:border-sky-400/10 dark:bg-[#081a2d]/92 dark:shadow-[0_1px_0_rgba(56,189,248,0.06)]">
        <button
          type="button"
          class="-m-2.5 rounded-md p-2.5 text-slate-500 transition-colors hover:bg-sky-50 hover:text-slate-900 lg:hidden dark:text-slate-300 dark:hover:bg-sky-400/10 dark:hover:text-white"
          phx-click={show_sidebar()}
        >
          <span class="sr-only">Open sidebar</span>
          <.icon name="hero-bars-3" class="size-6" />
        </button>

        <div aria-hidden="true" class="h-6 w-px bg-sky-100 lg:hidden dark:bg-sky-400/10"></div>

        <div class="flex flex-1 items-center gap-x-4 lg:gap-x-7">
          <div id="admin-topbar-search" class="flex flex-1 items-center">
            <label for="admin-topbar-search-input" class="sr-only">Search</label>
            <div class="relative w-full max-w-xl">
              <span class="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-4 text-slate-400 dark:text-slate-500">
                <.icon name="hero-magnifying-glass" class="size-5" />
              </span>
              <input
                id="admin-topbar-search-input"
                type="search"
                placeholder="Search..."
                disabled
                class="block w-full rounded-full border border-sky-100 bg-slate-50 py-2.5 pl-11 pr-4 text-sm text-slate-500 placeholder:text-slate-400 disabled:cursor-not-allowed disabled:opacity-100 focus:border-sky-200 focus:outline-none focus:ring-2 focus:ring-sky-100 dark:border-sky-400/10 dark:bg-[#0b2137] dark:text-slate-200 dark:placeholder:text-slate-500 dark:focus:border-sky-400/20 dark:focus:ring-sky-400/10"
              />
            </div>
          </div>

          <div class="ml-auto flex items-center gap-x-3 sm:gap-x-4 lg:gap-x-5">
            <div
              id="admin-topbar-utc-clock"
              phx-hook="AdminUtcClock"
              phx-update="ignore"
              data-utc-time={@utc_time}
              class="hidden items-center gap-x-1 text-xs font-medium text-slate-600 sm:flex dark:text-slate-300"
            >
              <span
                data-role="utc-time-value"
                class="font-mono tabular-nums text-slate-800 dark:text-slate-100"
              >
                {@utc_time}
              </span>
              <span class="uppercase tracking-[0.24em] text-slate-400 dark:text-slate-500">UTC</span>
            </div>

            <div class="hidden h-6 w-px bg-sky-100 sm:block dark:bg-sky-400/10"></div>

            <button
              id="admin-topbar-notification-bell"
              type="button"
              class="relative rounded-full p-2 text-slate-500 transition-colors hover:bg-sky-50 hover:text-slate-900 dark:text-slate-300 dark:hover:bg-sky-400/10 dark:hover:text-white"
            >
              <span class="sr-only">View notifications</span>
              <.icon name="hero-bell" class="size-6" />
              <span class="absolute right-1.5 top-1.5 size-2 rounded-full bg-sky-500 ring-2 ring-white dark:ring-[#081a2d]">
              </span>
            </button>

            <div class="h-6 w-px bg-sky-100 dark:bg-sky-400/10"></div>

            <div id="admin-topbar-user-menu-wrapper" class="relative">
              <button
                id="admin-topbar-user-menu-button"
                type="button"
                phx-click={toggle_user_menu()}
                phx-click-away={hide_user_menu()}
                class="flex items-center gap-x-3 rounded-full px-2 py-1.5 text-left transition-colors hover:bg-sky-50 dark:hover:bg-sky-400/10"
                aria-haspopup="true"
              >
                <span class="flex size-9 items-center justify-center rounded-full bg-sky-100 text-sm font-semibold text-sky-700 dark:bg-sky-400/10 dark:text-sky-200">
                  {@topbar_user_initial}
                </span>
                <span class="hidden min-w-0 md:block">
                  <span class="block text-[10px] font-semibold uppercase tracking-[0.22em] text-slate-400 dark:text-slate-500">
                    Signed In
                  </span>
                  <span class="block truncate text-sm font-semibold text-slate-900 dark:text-slate-100">
                    {@topbar_user_label}
                  </span>
                  <span class="block truncate text-xs text-slate-500 dark:text-slate-400">
                    Administrator
                  </span>
                </span>
                <.icon
                  name="hero-chevron-down"
                  class="hidden size-5 text-slate-400 md:block dark:text-slate-500"
                />
              </button>

              <div
                id="admin-topbar-user-menu"
                class="hidden absolute right-0 z-50 mt-3 w-56 overflow-hidden rounded-2xl border border-sky-100 bg-white shadow-xl dark:border-sky-400/10 dark:bg-[#0b1f34]"
              >
                <div class="border-b border-sky-100 px-4 py-3 dark:border-sky-400/10">
                  <p class="text-xs font-semibold uppercase tracking-[0.24em] text-slate-400 dark:text-slate-500">
                    Signed in
                  </p>
                  <p class="mt-1 truncate text-sm font-semibold text-slate-900 dark:text-slate-100">
                    {@topbar_user_label}
                  </p>
                </div>

                <div class="p-2">
                  <.link
                    href={~p"/sign-out"}
                    method="delete"
                    class="flex w-full items-center gap-x-3 rounded-xl px-3 py-2 text-sm font-medium text-slate-700 transition-colors hover:bg-sky-50 hover:text-slate-900 dark:text-slate-200 dark:hover:bg-sky-400/10 dark:hover:text-white"
                  >
                    <.icon
                      name="hero-arrow-right-start-on-rectangle"
                      class="size-5 text-slate-400 dark:text-slate-500"
                    /> Sign out
                  </.link>
                </div>
              </div>
            </div>

            <div id="admin-topbar-theme-toggle" class="shrink-0 scale-95 origin-right">
              <Layouts.theme_toggle />
            </div>
          </div>
        </div>
      </div>

      <main class="min-h-[calc(100vh-4rem)] bg-[#f3f8fd] dark:bg-[#04111f]">
        <div class="px-4 py-10 sm:px-6 lg:px-8">
          <div
            :if={@page_title != [] or @page_actions != []}
            class="mb-8 flex flex-col gap-4 border-b border-sky-100 pb-6 sm:flex-row sm:items-center sm:justify-between dark:border-sky-400/10"
          >
            <div :if={@page_title != []} class="space-y-1">
              <p class="text-xs font-semibold uppercase tracking-[0.3em] text-sky-600 dark:text-sky-300">
                Admin
              </p>
              <div
                id="admin-page-title"
                class="text-2xl font-semibold tracking-tight text-slate-950 dark:text-white"
              >
                {render_slot(@page_title)}
              </div>
            </div>

            <div :if={@page_actions != []} class="flex flex-wrap gap-3">
              {render_slot(@page_actions)}
            </div>
          </div>

          {render_slot(@inner_block)}
        </div>
      </main>
    </div>

    <Layouts.flash_group flash={@flash} />
    """
  end

  attr :container_id, :string, default: nil
  attr :image_id, :string, default: nil

  defp brand_logo(assigns) do
    ~H"""
    <div id={@container_id} class="relative h-12 w-56 overflow-hidden">
      <img
        id={@image_id}
        src={~p"/images/revenuelink_main.png"}
        alt="RevenueLink Technologies"
        class="absolute left-1/2 top-1/2 w-[150%] max-w-none -translate-x-1/2 -translate-y-1/2"
      />
    </div>
    """
  end

  attr :current_path, :string, required: true

  defp sidebar_nav(assigns) do
    ~H"""
    <nav class="flex flex-1 flex-col">
      <ul role="list" class="flex flex-1 flex-col gap-y-7">
        <li>
          <ul role="list" class="-mx-2 space-y-1">
            <li>
              <.link
                navigate={~p"/admin"}
                class={[
                  "group flex gap-x-3 rounded-xl px-3 py-2.5 text-sm/6 font-semibold transition-colors",
                  if(@current_path == "/admin",
                    do: "bg-white/14 text-white shadow-[inset_0_1px_0_rgba(255,255,255,0.08)]",
                    else: "text-sky-50/85 hover:bg-white/8 hover:text-white"
                  )
                ]}
              >
                <.icon
                  name="hero-home"
                  class={[
                    "size-6 shrink-0",
                    if(@current_path == "/admin",
                      do: "text-white",
                      else: "text-sky-200/90 group-hover:text-white"
                    )
                  ]}
                /> Dashboard
              </.link>
            </li>
            <li>
              <.link
                navigate={~p"/admin/leads"}
                class={[
                  "group flex gap-x-3 rounded-xl px-3 py-2.5 text-sm/6 font-semibold transition-colors",
                  if(String.starts_with?(@current_path, "/admin/leads"),
                    do: "bg-white/14 text-white shadow-[inset_0_1px_0_rgba(255,255,255,0.08)]",
                    else: "text-sky-50/85 hover:bg-white/8 hover:text-white"
                  )
                ]}
              >
                <.icon
                  name="hero-inbox"
                  class={[
                    "size-6 shrink-0",
                    if(String.starts_with?(@current_path, "/admin/leads"),
                      do: "text-white",
                      else: "text-sky-200/90 group-hover:text-white"
                    )
                  ]}
                /> Leads
              </.link>
            </li>
            <li>
              <.link
                navigate={~p"/admin/estimates"}
                class={[
                  "group flex gap-x-3 rounded-xl px-3 py-2.5 text-sm/6 font-semibold transition-colors",
                  if(String.starts_with?(@current_path, "/admin/estimates"),
                    do: "bg-white/14 text-white shadow-[inset_0_1px_0_rgba(255,255,255,0.08)]",
                    else: "text-sky-50/85 hover:bg-white/8 hover:text-white"
                  )
                ]}
              >
                <.icon
                  name="hero-document-text"
                  class={[
                    "size-6 shrink-0",
                    if(String.starts_with?(@current_path, "/admin/estimates"),
                      do: "text-white",
                      else: "text-sky-200/90 group-hover:text-white"
                    )
                  ]}
                /> Estimate Requests
              </.link>
            </li>
            <li>
              <.link
                navigate={~p"/admin/visitors"}
                class={[
                  "group flex gap-x-3 rounded-xl px-3 py-2.5 text-sm/6 font-semibold transition-colors",
                  if(String.starts_with?(@current_path, "/admin/visitors"),
                    do: "bg-white/14 text-white shadow-[inset_0_1px_0_rgba(255,255,255,0.08)]",
                    else: "text-sky-50/85 hover:bg-white/8 hover:text-white"
                  )
                ]}
              >
                <.icon
                  name="hero-eye"
                  class={[
                    "size-6 shrink-0",
                    if(String.starts_with?(@current_path, "/admin/visitors"),
                      do: "text-white",
                      else: "text-sky-200/90 group-hover:text-white"
                    )
                  ]}
                /> Visitors
              </.link>
            </li>
          </ul>
        </li>
        <li class="mt-auto">
          <.link
            navigate={~p"/"}
            class="group -mx-2 flex gap-x-3 rounded-xl px-3 py-2.5 text-sm/6 font-semibold text-sky-50/85 transition-colors hover:bg-white/8 hover:text-white"
          >
            <.icon
              name="hero-arrow-left"
              class="size-6 shrink-0 text-sky-200/90 group-hover:text-white"
            /> Back to Site
          </.link>
        </li>
      </ul>
    </nav>
    """
  end

  defp show_sidebar(js \\ %JS{}) do
    js
    |> JS.remove_class("-translate-x-full", to: "#mobile-sidebar")
    |> JS.add_class("translate-x-0", to: "#mobile-sidebar")
    |> JS.show(to: "#mobile-sidebar-backdrop")
  end

  defp hide_sidebar(js \\ %JS{}) do
    js
    |> JS.add_class("-translate-x-full", to: "#mobile-sidebar")
    |> JS.remove_class("translate-x-0", to: "#mobile-sidebar")
    |> JS.hide(to: "#mobile-sidebar-backdrop")
  end

  defp toggle_user_menu(js \\ %JS{}) do
    JS.toggle(js,
      to: "#admin-topbar-user-menu",
      in: {"transition ease-out duration-200", "opacity-0 scale-95", "opacity-100 scale-100"},
      out: {"transition ease-in duration-150", "opacity-100 scale-100", "opacity-0 scale-95"}
    )
  end

  defp hide_user_menu(js \\ %JS{}) do
    JS.hide(js,
      to: "#admin-topbar-user-menu",
      transition:
        {"transition ease-in duration-150", "opacity-100 scale-100", "opacity-0 scale-95"}
    )
  end

  defp format_utc_time(%DateTime{} = datetime) do
    datetime
    |> DateTime.to_time()
    |> Time.truncate(:second)
    |> Time.to_iso8601()
  end

  defp topbar_user_label(%{email: email}) when not is_nil(email) do
    email
    |> to_string()
    |> case do
      "" -> "Admin user"
      value -> value
    end
  end

  defp topbar_user_label(_current_user), do: "Admin user"

  defp topbar_user_initial(current_user) do
    current_user
    |> topbar_user_label()
    |> String.first()
    |> case do
      nil -> "A"
      initial -> String.upcase(initial)
    end
  end
end
