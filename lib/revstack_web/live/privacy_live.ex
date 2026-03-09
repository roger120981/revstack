defmodule RevstackWeb.PrivacyLive do
  use RevstackWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, page_title: "Privacy Policy — RevenueLink Technologies", current_path: "/privacy")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_user={assigns[:current_user]} current_path={@current_path}>
      <section class="py-16 sm:py-24">
        <div class="mx-auto max-w-3xl">
          <div class="text-center mb-12">
            <h1 class="text-4xl sm:text-5xl font-extrabold tracking-tight text-base-content">
              Privacy <span class="text-primary">Policy</span>
            </h1>
            <div class="mt-4 w-16 h-1 bg-primary mx-auto rounded-full"></div>
          </div>

          <div class="prose prose-lg mx-auto space-y-8">
            <div class="rounded-2xl border border-base-300 bg-base-100 p-6 sm:p-8 shadow-sm space-y-6">
              <div>
                <h2 class="text-xl font-bold text-base-content mb-3">Data Collection</h2>
                <p class="text-base-content/80 leading-relaxed">
                  Your personal information (name, email, phone, company) is collected only when you
                  voluntarily submit it through our contact or estimate request forms. This data
                  is collected solely for the purpose of responding to your inquiry.
                </p>
              </div>

              <div class="divider"></div>

              <div>
                <h2 class="text-xl font-bold text-base-content mb-3">Data Usage</h2>
                <p class="text-base-content/80 leading-relaxed">
                  Your personal data will never be sold, rented, or shared with third parties for
                  marketing purposes. We use your information exclusively to respond to your
                  inquiries and to facilitate potential business engagements.
                </p>
              </div>

              <div class="divider"></div>

              <div>
                <h2 class="text-xl font-bold text-base-content mb-3">Data Deletion</h2>
                <p class="text-base-content/80 leading-relaxed">
                  You may request deletion of your personal data at any time by contacting me
                  at <a
                    href="mailto:kyle.neal.lucidsoftwaresolutions@gmail.com"
                    class="text-primary hover:underline"
                  >kyle.neal.lucidsoftwaresolutions@gmail.com</a>.
                  I will process your request within a reasonable timeframe.
                </p>
              </div>

              <div class="divider"></div>

              <div>
                <h2 class="text-xl font-bold text-base-content mb-3">Contact</h2>
                <p class="text-base-content/80 leading-relaxed">
                  If you have any questions about this privacy policy, please contact me at <a
                    href="mailto:kyle.neal.lucidsoftwaresolutions@gmail.com"
                    class="text-primary hover:underline"
                  >kyle.neal.lucidsoftwaresolutions@gmail.com</a>.
                </p>
              </div>
            </div>

            <p class="text-sm text-base-content/50 text-center">
              Last updated: February 2026
            </p>
          </div>
        </div>
      </section>
    </Layouts.app>
    """
  end
end
