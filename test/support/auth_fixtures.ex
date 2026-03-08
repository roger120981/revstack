defmodule Revstack.TestSupport.AuthFixtures do
  import Phoenix.ConnTest

  alias AshAuthentication.Plug.Helpers
  alias Revstack.Accounts.User
  alias Revstack.Consulting.{EstimateRequest, Lead}

  @default_password "supersecret123!"

  def create_user(attrs \\ %{}) do
    email = Map.get(attrs, :email, unique_email("user"))
    password = Map.get(attrs, :password, @default_password)
    admin? = Map.get(attrs, :admin?, false)

    changeset =
      User
      |> Ash.Changeset.for_create(
        :register_with_password,
        %{email: email, password: password, password_confirmation: password},
        authorize?: false
      )

    changeset =
      if admin? do
        Ash.Changeset.force_change_attribute(changeset, :admin?, true)
      else
        changeset
      end

    Ash.create!(changeset, authorize?: false)
  end

  def create_and_sign_in_user(attrs \\ %{}) do
    password = Map.get(attrs, :password, @default_password)

    user =
      attrs
      |> Map.put(:password, password)
      |> create_user()

    sign_in_user(to_string(user.email), password)
  end

  def sign_in_user(email, password) do
    User
    |> Ash.Query.for_read(
      :sign_in_with_password,
      %{email: email, password: password},
      authorize?: false
    )
    |> Ash.read_one!(authorize?: false)
  end

  def log_in_user(conn, user) do
    conn
    |> init_test_session(%{})
    |> Helpers.store_in_session(user)
  end

  def create_lead(attrs \\ %{}) do
    {status, attrs} = Map.pop(attrs, :status)

    params =
      Map.merge(
        %{
          name: "Lead #{System.unique_integer([:positive])}",
          email: unique_email("lead"),
          company: "RevenueLink",
          message: "This is a detailed lead message that is comfortably over twenty characters.",
          preferred_contact_method: :email,
          phone: nil,
          source: "website",
          honeypot: ""
        },
        attrs
      )

    lead =
      Lead
      |> Ash.Changeset.for_create(:create, params, authorize?: false)
      |> Ash.create!(authorize?: false)

    if status && status != :new do
      lead
      |> Ash.Changeset.for_update(:update_status, %{status: status}, authorize?: false)
      |> Ash.update!(authorize?: false)
    else
      lead
    end
  end

  def create_estimate_request(attrs \\ %{}) do
    {status, attrs} = Map.pop(attrs, :status)
    {internal_size_tag, attrs} = Map.pop(attrs, :internal_size_tag)

    params =
      Map.merge(
        %{
          name: "Estimate #{System.unique_integer([:positive])}",
          email: unique_email("estimate"),
          company: "RevenueLink",
          project_type: :phoenix_liveview_app,
          budget_range: :"15k_50k",
          timeline: :"1_2_months",
          summary:
            "This is a detailed estimate summary that is comfortably over thirty characters.",
          details: "Needs a production-grade admin interface and BEAM expertise.",
          source: "website"
        },
        attrs
      )

    estimate =
      EstimateRequest
      |> Ash.Changeset.for_create(:create, params, authorize?: false)
      |> Ash.create!(authorize?: false)

    if (status && status != :new) || internal_size_tag do
      update_params = %{}
      update_params = if status, do: Map.put(update_params, :status, status), else: update_params

      update_params =
        if internal_size_tag do
          Map.put(update_params, :internal_size_tag, internal_size_tag)
        else
          update_params
        end

      estimate
      |> Ash.Changeset.for_update(:update_status, update_params, authorize?: false)
      |> Ash.update!(authorize?: false)
    else
      estimate
    end
  end

  defp unique_email(prefix) do
    "#{prefix}-#{System.unique_integer([:positive])}@example.com"
  end
end
