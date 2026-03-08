defmodule Revstack.Accounts.User do
  use Ash.Resource,
    otp_app: :revstack,
    domain: Revstack.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshAuthentication]

  authentication do
    add_ons do
      log_out_everywhere do
        apply_on_password_change?(true)
      end
    end

    tokens do
      enabled?(true)
      token_resource(Revstack.Accounts.Token)
      signing_secret(Revstack.Secrets)
      store_all_tokens?(true)
      require_token_presence_for_authentication?(true)
    end

    strategies do
      password :password do
        identity_field(:email)

        sign_in_tokens_enabled?(true)

        resettable do
          sender(Revstack.Accounts.User.Senders.SendPasswordResetEmail)
          # Token validity in hours
          token_lifetime({24, :hours})
        end
      end

      remember_me(:remember_me)
    end
  end

  postgres do
    table "users"
    repo(Revstack.Repo)
  end

  actions do
    defaults [:read]

    read :get_by_subject do
      description "Get a user by the subject claim in a JWT"
      argument :subject, :string, allow_nil?: false
      get? true
      prepare AshAuthentication.Preparations.FilterBySubject
    end

    read :get_by_email do
      description "Looks up a user by their email"
      get_by :email
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string do
      allow_nil? false
      public? true
    end

    attribute :hashed_password, :string do
      allow_nil? true
      sensitive? true
    end

    attribute :admin?, :boolean do
      allow_nil? false
      default false
      public? true
    end
  end

  identities do
    identity :unique_email, [:email]
  end
end
