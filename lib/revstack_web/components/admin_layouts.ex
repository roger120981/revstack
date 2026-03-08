defmodule RevstackWeb.AdminLayouts do
  @moduledoc """
  Admin panel layout with indigo sidebar navigation.
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
      <div class="relative flex h-full grow flex-col gap-y-5 overflow-y-auto bg-indigo-800 px-6 pb-4 ring-1 ring-white/10">
        <div class="flex h-16 shrink-0 items-center justify-between">
          <.brand_logo container_id="mobile-brand-logo" image_id="mobile-brand-logo-image" />
          <button
            type="button"
            class="-m-2.5 p-2.5 text-indigo-200 hover:text-white lg:hidden"
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
      <div class="relative flex grow flex-col gap-y-5 overflow-y-auto bg-indigo-800 px-6 pb-4 after:pointer-events-none after:absolute after:inset-y-0 after:right-0 after:w-px after:bg-white/10">
        <div class="flex h-16 shrink-0 items-center">
          <.brand_logo container_id="desktop-brand-logo" image_id="desktop-brand-logo-image" />
        </div>
        <.sidebar_nav current_path={@current_path} />
      </div>
    </div>

    <%!-- Main content area --%>
    <div class="lg:pl-72">
      <%!-- Top bar --%>
      <div class="sticky top-0 z-40 flex h-16 shrink-0 items-center gap-x-4 border-b border-white/10 bg-gray-900 px-4 sm:gap-x-6 sm:px-6 lg:px-8">
        <button
          type="button"
          class="-m-2.5 p-2.5 text-gray-400 hover:text-white lg:hidden"
          phx-click={show_sidebar()}
        >
          <span class="sr-only">Open sidebar</span>
          <.icon name="hero-bars-3" class="size-6" />
        </button>

        <div aria-hidden="true" class="h-6 w-px bg-white/10 lg:hidden"></div>

        <div class="flex flex-1 items-center justify-between gap-x-4 lg:gap-x-6">
          <div class="text-sm font-semibold text-white">
            {render_slot(@page_title)}
          </div>
          <div class="flex items-center gap-x-4 lg:gap-x-6">
            <div class="flex items-center gap-x-3">
              <span class="text-sm text-gray-300">{@current_user.email}</span>
              <.link
                href={~p"/sign-out"}
                method="delete"
                class="rounded-md bg-indigo-600 px-3 py-1.5 text-xs font-semibold text-white shadow-sm hover:bg-indigo-500 transition-colors"
              >
                Sign out
              </.link>
            </div>
          </div>
        </div>
      </div>

      <main class="bg-gray-900 min-h-[calc(100vh-4rem)]">
        <div class="px-4 py-10 sm:px-6 lg:px-8">
          <div :if={@page_actions != []} class="flex items-center justify-between mb-8">
            <div></div>
            <div class="flex gap-3">{render_slot(@page_actions)}</div>
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
                  "group flex gap-x-3 rounded-md p-2 text-sm/6 font-semibold transition-colors",
                  if(@current_path == "/admin",
                    do: "bg-indigo-950/25 text-white",
                    else: "text-indigo-100 hover:bg-indigo-950/25 hover:text-white"
                  )
                ]}
              >
                <.icon
                  name="hero-home"
                  class={[
                    "size-6 shrink-0",
                    if(@current_path == "/admin",
                      do: "text-white",
                      else: "text-indigo-100 group-hover:text-white"
                    )
                  ]}
                /> Dashboard
              </.link>
            </li>
            <li>
              <.link
                navigate={~p"/admin/leads"}
                class={[
                  "group flex gap-x-3 rounded-md p-2 text-sm/6 font-semibold transition-colors",
                  if(String.starts_with?(@current_path, "/admin/leads"),
                    do: "bg-indigo-950/25 text-white",
                    else: "text-indigo-100 hover:bg-indigo-950/25 hover:text-white"
                  )
                ]}
              >
                <.icon
                  name="hero-inbox"
                  class={[
                    "size-6 shrink-0",
                    if(String.starts_with?(@current_path, "/admin/leads"),
                      do: "text-white",
                      else: "text-indigo-100 group-hover:text-white"
                    )
                  ]}
                /> Leads
              </.link>
            </li>
            <li>
              <.link
                navigate={~p"/admin/estimates"}
                class={[
                  "group flex gap-x-3 rounded-md p-2 text-sm/6 font-semibold transition-colors",
                  if(String.starts_with?(@current_path, "/admin/estimates"),
                    do: "bg-indigo-950/25 text-white",
                    else: "text-indigo-100 hover:bg-indigo-950/25 hover:text-white"
                  )
                ]}
              >
                <.icon
                  name="hero-document-text"
                  class={[
                    "size-6 shrink-0",
                    if(String.starts_with?(@current_path, "/admin/estimates"),
                      do: "text-white",
                      else: "text-indigo-100 group-hover:text-white"
                    )
                  ]}
                /> Estimate Requests
              </.link>
            </li>
            <li>
              <.link
                navigate={~p"/admin/visitors"}
                class={[
                  "group flex gap-x-3 rounded-md p-2 text-sm/6 font-semibold transition-colors",
                  if(String.starts_with?(@current_path, "/admin/visitors"),
                    do: "bg-indigo-950/25 text-white",
                    else: "text-indigo-100 hover:bg-indigo-950/25 hover:text-white"
                  )
                ]}
              >
                <.icon
                  name="hero-eye"
                  class={[
                    "size-6 shrink-0",
                    if(String.starts_with?(@current_path, "/admin/visitors"),
                      do: "text-white",
                      else: "text-indigo-100 group-hover:text-white"
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
            class="group -mx-2 flex gap-x-3 rounded-md p-2 text-sm/6 font-semibold text-indigo-100 hover:bg-indigo-950/25 hover:text-white transition-colors"
          >
            <.icon
              name="hero-arrow-left"
              class="size-6 shrink-0 text-indigo-100 group-hover:text-white"
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
end
