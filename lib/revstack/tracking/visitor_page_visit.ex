defmodule Revstack.Tracking.VisitorPageVisit do
  use Ash.Resource,
    otp_app: :revstack,
    domain: Revstack.Tracking,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "visitor_page_visits"
    repo(Revstack.Repo)
  end

  code_interface do
    define :create, action: :create
    define :read, action: :read
    define :for_visitor, action: :for_visitor, args: [:visitor_id]
    define :destroy, action: :destroy
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [
        :path,
        :full_url,
        :query_string,
        :method,
        :referrer,
        :visitor_id
      ]

      change set_attribute(:visited_at, &DateTime.utc_now/0)
    end

    read :for_visitor do
      argument :visitor_id, :uuid, allow_nil?: false

      filter expr(visitor_id == ^arg(:visitor_id))

      prepare build(sort: [visited_at: :desc])
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

  relationships do
    belongs_to :visitor, Revstack.Tracking.Visitor do
      allow_nil? false
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :path, :string do
      allow_nil? false
      public? true
    end

    attribute :full_url, :string do
      allow_nil? true
      public? true
    end

    attribute :query_string, :string do
      allow_nil? true
      public? true
    end

    attribute :method, :string do
      allow_nil? true
      public? true
    end

    attribute :referrer, :string do
      allow_nil? true
      public? true
    end

    attribute :visited_at, :utc_datetime do
      allow_nil? false
      public? true
    end

    timestamps()
  end
end
