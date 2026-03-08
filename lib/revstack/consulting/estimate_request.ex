defmodule Revstack.Consulting.EstimateRequest do
  use Ash.Resource,
    otp_app: :revstack,
    domain: Revstack.Consulting,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  @supported_project_types [
    :phoenix_liveview_app,
    :api_backend,
    :erlang_service,
    :modernization,
    :devops_reliability,
    :beam_consulting,
    :phoenix_liveview_application,
    :custom_web_application,
    :distributed_system_architecture,
    :production_debugging_reliability,
    :gaming_pc_build,
    :small_business_network_setup,
    :technology_consulting,
    :other
  ]

  postgres do
    table "estimate_requests"
    repo(Revstack.Repo)
  end

  code_interface do
    define :create, action: :create
    define :read, action: :read
    define :update_status, action: :update_status
    define :destroy, action: :destroy
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [
        :name,
        :email,
        :company,
        :project_type,
        :budget_range,
        :timeline,
        :summary,
        :details,
        :source,
        :visitor_id,
        :request_ip,
        :request_user_agent
      ]
    end

    update :update_status do
      require_atomic? false
      accept [:status, :internal_size_tag]
    end
  end

  policies do
    policy action(:create) do
      authorize_if always()
    end

    policy action_type([:read, :update, :destroy]) do
      authorize_if actor_attribute_equals(:admin?, true)
    end
  end

  validations do
    validate match(:email, ~r/^[^\s]+@[^\s]+\.[^\s]+$/) do
      message "must be a valid email address"
    end

    validate string_length(:summary, min: 30) do
      message "must be at least 30 characters"
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :email, :string do
      allow_nil? false
      public? true
    end

    attribute :company, :string do
      allow_nil? true
      public? true
    end

    attribute :project_type, :atom do
      allow_nil? false
      public? true

      constraints one_of: @supported_project_types
    end

    attribute :budget_range, :atom do
      allow_nil? true
      public? true
      constraints one_of: [:under_5k, :"5k_15k", :"15k_50k", :"50k_plus", :unknown]
    end

    attribute :timeline, :atom do
      allow_nil? true
      public? true
      constraints one_of: [:asap, :"1_2_months", :"3_6_months", :flexible]
    end

    attribute :summary, :string do
      allow_nil? false
      public? true
      constraints min_length: 30
    end

    attribute :details, :string do
      allow_nil? true
      public? true
    end

    attribute :status, :atom do
      allow_nil? false
      public? true
      default :new
      constraints one_of: [:new, :in_review, :responded, :closed]
    end

    attribute :internal_size_tag, :atom do
      allow_nil? true
      public? true
      constraints one_of: [:small, :medium, :large, :unknown]
    end

    attribute :source, :string do
      allow_nil? true
      public? true
      default "website"
    end

    attribute :visitor_id, :uuid do
      allow_nil? true
      public? true
    end

    attribute :request_ip, :string do
      allow_nil? true
      public? true
    end

    attribute :request_user_agent, :string do
      allow_nil? true
      public? true
    end

    timestamps()
  end
end
