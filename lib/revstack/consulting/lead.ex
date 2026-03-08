defmodule Revstack.Consulting.Lead do
  use Ash.Resource,
    otp_app: :revstack,
    domain: Revstack.Consulting,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  postgres do
    table "leads"
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
        :message,
        :preferred_contact_method,
        :phone,
        :source,
        :honeypot
      ]
    end

    update :update_status do
      require_atomic? false
      accept [:status]
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

    validate string_length(:message, min: 20) do
      message "must be at least 20 characters"
    end

    validate present(:phone) do
      where [attribute_equals(:preferred_contact_method, :phone)]
      message "is required when preferred contact method is phone"
    end

    validate attribute_equals(:honeypot, "") do
      message "must be empty"
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

    attribute :message, :string do
      allow_nil? false
      public? true
      constraints min_length: 20
    end

    attribute :preferred_contact_method, :atom do
      allow_nil? false
      public? true
      default :email
      constraints one_of: [:email, :phone, :either]
    end

    attribute :phone, :string do
      allow_nil? true
      public? true
    end

    attribute :status, :atom do
      allow_nil? false
      public? true
      default :new
      constraints one_of: [:new, :contacted, :closed]
    end

    attribute :source, :string do
      allow_nil? true
      public? true
      default "website"
    end

    attribute :honeypot, :string do
      allow_nil? true
      public? true
      default ""
    end

    timestamps()
  end
end
