defmodule Revstack.Tracking.Visitor do
  use Ash.Resource,
    otp_app: :revstack,
    domain: Revstack.Tracking,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "visitors"
    repo(Revstack.Repo)
  end

  code_interface do
    define :create, action: :create
    define :read, action: :read
    define :by_ip, action: :by_ip, args: [:ip_address]
    define :record_visit, action: :record_visit
    define :enrich_location, action: :enrich_location
    define :destroy, action: :destroy
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [
        :ip_address,
        :user_agent,
        :referrer,
        :ip_location_city,
        :ip_location_region,
        :ip_location_country,
        :ip_location_latitude,
        :ip_location_longitude
      ]

      change set_attribute(:first_visited_at, &DateTime.utc_now/0)
      change set_attribute(:last_visited_at, &DateTime.utc_now/0)
      change set_attribute(:visit_count, 1)
    end

    read :by_ip do
      argument :ip_address, :string, allow_nil?: false
      get? true

      filter expr(ip_address == ^arg(:ip_address))
    end

    update :record_visit do
      require_atomic? false

      change set_attribute(:last_visited_at, &DateTime.utc_now/0)
      change increment(:visit_count)
    end

    update :enrich_location do
      require_atomic? false

      accept [
        :ip_location_city,
        :ip_location_region,
        :ip_location_country,
        :ip_location_latitude,
        :ip_location_longitude
      ]
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

  aggregates do
    count :lead_count, :leads
    count :estimate_count, :estimate_requests

    count :resume_view_count, :page_visits do
      filter expr(path == "/resume/view")
    end

    count :resume_download_count, :page_visits do
      filter expr(path == "/resume/download")
    end
  end

  relationships do
    has_many :page_visits, Revstack.Tracking.VisitorPageVisit

    has_many :leads, Revstack.Consulting.Lead do
      no_attributes? true
      filter expr(request_ip == parent(ip_address))
    end

    has_many :estimate_requests, Revstack.Consulting.EstimateRequest do
      no_attributes? true
      filter expr(request_ip == parent(ip_address))
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :ip_address, :string do
      allow_nil? false
      public? true
    end

    attribute :ip_location_city, :string do
      allow_nil? true
      public? true
    end

    attribute :ip_location_region, :string do
      allow_nil? true
      public? true
    end

    attribute :ip_location_country, :string do
      allow_nil? true
      public? true
    end

    attribute :ip_location_latitude, :float do
      allow_nil? true
      public? true
    end

    attribute :ip_location_longitude, :float do
      allow_nil? true
      public? true
    end

    attribute :user_agent, :string do
      allow_nil? true
      public? true
    end

    attribute :referrer, :string do
      allow_nil? true
      public? true
    end

    attribute :first_visited_at, :utc_datetime do
      allow_nil? false
      public? true
    end

    attribute :last_visited_at, :utc_datetime do
      allow_nil? false
      public? true
    end

    attribute :visit_count, :integer do
      allow_nil? false
      public? true
      default 0
    end

    timestamps()
  end

  identities do
    identity :unique_ip, [:ip_address]
  end
end
