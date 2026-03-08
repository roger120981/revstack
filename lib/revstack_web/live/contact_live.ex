defmodule RevstackWeb.ContactLive do
  use RevstackWeb, :live_view

  @impl true
  def mount(_params, session, socket) do
    form =
      Revstack.Consulting.Lead
      |> AshPhoenix.Form.for_create(:create,
        forms: [auto?: true]
      )
      |> to_form()

    {:ok,
     socket
     |> assign(page_title: "Contact — Revstack")
     |> assign(form: form)
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
      {:ok, _lead} ->
        {:noreply,
         socket
         |> put_flash(:info, "Thank you! I'll be in touch soon.")
         |> push_navigate(to: ~p"/thanks")}

      {:error, form} ->
        {:noreply, assign(socket, form: to_form(form))}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={assigns[:current_user]}>
      <section class="py-16 sm:py-24">
        <div class="mx-auto max-w-2xl">
          <div class="text-center mb-12">
            <h1 class="text-4xl sm:text-5xl font-extrabold tracking-tight text-base-content">
              Get in <span class="text-primary">Touch</span>
            </h1>
            <div class="mt-4 w-16 h-1 bg-primary mx-auto rounded-full"></div>
            <p class="mt-6 text-lg text-base-content/70 leading-relaxed">
              Have a question or want to discuss a project? Send me a message.
            </p>
          </div>

          <div class="rounded-2xl border border-base-300 bg-base-100 p-6 sm:p-8 shadow-sm">
            <.form
              for={@form}
              id="contact-form"
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
                field={@form[:preferred_contact_method]}
                type="select"
                label="Preferred Contact Method"
                options={[
                  {"Email", "email"},
                  {"Phone", "phone"},
                  {"Either", "either"}
                ]}
              />

              <%= if to_string(@form[:preferred_contact_method].value) in ["phone", "either"] do %>
                <.input
                  field={@form[:phone]}
                  type="tel"
                  label="Phone Number"
                  placeholder="+1 (555) 123-4567"
                />
              <% end %>

              <.input
                field={@form[:message]}
                type="textarea"
                label="Message"
                placeholder="Tell me about your project or question (at least 20 characters)..."
                rows="5"
                required
              />

              <%!-- Honeypot field --%>
              <div class="hidden" aria-hidden="true">
                <.input
                  field={@form[:honeypot]}
                  label="Leave this empty"
                  autocomplete="off"
                  tabindex="-1"
                />
              </div>

              <.input field={@form[:source]} type="hidden" value="website" />

              <div class="pt-4">
                <button
                  type="submit"
                  class="btn btn-primary btn-lg w-full gap-2 shadow-lg hover:shadow-xl transition-all duration-300"
                >
                  <.icon name="hero-paper-airplane" class="size-5" /> Send Message
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
