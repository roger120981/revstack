# Revstack

A Phoenix LiveView consulting website for RevenueLink Technologies LLC, focused on Elixir and Erlang consulting services, lead intake, estimate intake, and admin operations.

Live site: [https://revstack.fly.dev/](https://revstack.fly.dev/)

## Features

### Public routes
- Home/profile (`/`, `/whoami`) with project highlights and technical background
- About (`/about`)
- Services (`/services`)
- Estimate request form (`/estimate`)
- Contact form (`/contact`)
- Privacy page (`/privacy`)
- Thank-you page (`/thanks`)
- Resume delivery endpoints:
  - Inline view: `/resume/kyle-neal-resume.pdf`
  - Attachment download: `/resume/download/kyle-neal-resume.pdf`

### Admin routes
- Dashboard (`/admin`)
- Leads (`/admin/leads`, detail/edit views)
- Estimates (`/admin/estimates`, detail/edit views)
- Visitors (`/admin/visitors`, detail view)

### Authentication and authorization
- Email/password authentication via AshAuthentication
- Sign-in token support (magic-link flow)
- Password reset flow
- Remember-me support
- Admin-only access for dashboard and data management
- Public create actions for lead and estimate intake

### Visitor tracking and analytics
- Request/session visitor context capture via plug
- LiveView navigation-aware page-visit tracking
- Visitor resource with visit counters and first/last seen timestamps
- Page visit resource with path, full URL, method, and timestamp
- Optional async geolocation enrichment via MaxMind using Req
- Resume view/download events tracked as page visits

## Tech stack

- Elixir `~> 1.15`
- Erlang/OTP 28+
- Phoenix `~> 1.8.4`
- Phoenix LiveView `~> 1.1.0`
- Ash `~> 3.0`
- AshPostgres `~> 2.0`
- AshAuthentication `~> 4.0`
- AshAuthentication.Phoenix `~> 2.0`
- AshAdmin `~> 0.14`
- PostgreSQL
- Tailwind CSS v4
- daisyUI plugins (for theme and auth UI integration)
- Req (HTTP client)
- Bandit (web server)
- Swoosh (email)

## Core data resources

### `Revstack.Consulting.Lead`
- Contact fields: `name`, `email`, `company`, `phone`
- Message and contact preference fields
- Tracking fields: `source`, `visitor_id`, `request_ip`, `request_user_agent`
- Status workflow: `new`, `contacted`, `closed`
- Validations:
  - email format
  - message minimum length (20)
  - phone required when preferred contact method is `phone`
  - honeypot must be empty

### `Revstack.Consulting.EstimateRequest`
- Contact fields: `name`, `email`, `company`
- Project fields: `project_type`, `budget_range`, `timeline`, `summary`, `details`
- Tracking fields: `source`, `visitor_id`, `request_ip`, `request_user_agent`
- Admin fields: `status`, `internal_size_tag`
- Status workflow: `new`, `in_review`, `responded`, `closed`
- Validations:
  - email format
  - summary minimum length (30)

Supported `project_type` values include:
- `phoenix_liveview_app`
- `api_backend`
- `erlang_service`
- `modernization`
- `devops_reliability`
- `beam_consulting`
- `phoenix_liveview_application`
- `custom_web_application`
- `distributed_system_architecture`
- `production_debugging_reliability`
- `gaming_pc_build`
- `small_business_network_setup`
- `technology_consulting`
- `other`

### `Revstack.Tracking.Visitor`
- Identified by IP (`unique_ip` identity)
- Captures user agent/referrer and geolocation fields
- Visit counters (`visit_count`) and first/last visit timestamps
- Aggregates:
  - lead count
  - estimate count
  - resume view count
  - resume download count

### `Revstack.Tracking.VisitorPageVisit`
- Linked to visitor
- Stores path, full URL, query string, HTTP method, visited timestamp
- Used for admin visitor activity timelines

### `Revstack.Accounts.User`
- Authentication credentials (email/password)
- Admin authorization flag (`admin?`)

## Getting started

### Prerequisites
- Elixir 1.15+
- Erlang/OTP 28+
- PostgreSQL
- Node.js (for assets)

### Setup

```bash
mix setup
```

This runs:
- `mix deps.get`
- `mix ash.setup`
- `mix assets.setup`
- `mix assets.build`
- `mix run priv/repo/seeds.exs`

### Run locally

```bash
mix phx.server
```

or:

```bash
iex -S mix phx.server
```

Visit [http://localhost:4000](http://localhost:4000).

## Common development commands

- `mix test`
- `mix test --failed`
- `mix test test/path/to/file.exs`
- `mix precommit`
- `mix assets.build`
- `mix assets.deploy`
- `mix assets.sync`

## Development-only tooling

When `:dev_routes` is enabled:
- LiveDashboard: `/dev/dashboard`
- Swoosh mailbox preview: `/dev/mailbox`
- AshAdmin: `/dev/ash-admin`

## Test suite layout

```text
test/
  revstack/
    mix_project_test.exs
    repo_config_test.exs
    repo_test.exs
    seeds_test.exs
    tracking/
      error_logger_test.exs
      geolocation_test.exs
      maxmind_integration_test.exs
      service_test.exs
      visitor_resource_test.exs
      visitor_page_visit_resource_test.exs
  revstack_web/
    admin_auth_access_test.exs
    admin_dashboard_live_test.exs
    admin_lead_live_test.exs
    admin_estimate_request_live_test.exs
    admin_visitor_live_test.exs
    contact_live_test.exs
    estimate_live_test.exs
    live_visitor_tracking_test.exs
    services_live_test.exs
    whoami_live_career_modal_test.exs
    whoami_live_projects_test.exs
    resume_controller_test.exs
    layouts_navigation_test.exs
    layouts_scroll_top_test.exs
    layouts_user_menu_test.exs
    controllers/
      error_html_test.exs
      error_json_test.exs
      page_controller_test.exs
    plugs/
      visitor_tracking_test.exs
  support/
    auth_fixtures.ex
    conn_case.ex
    data_case.ex
  test_helper.exs
```

## Deployment

Currently deployed on Fly.io at [https://revstack.fly.dev/](https://revstack.fly.dev/).

### Required environment variables
- `SECRET_KEY_BASE`
- `DATABASE_URL`
- `PHX_SERVER=true`

### Optional environment variables
- `PORT`
- `POOL_SIZE`
- `ECTO_IPV6`
- `MAXMIND_ACCOUNT_ID`
- `MAXMIND_LICENSE_KEY`
- `MAXMIND_BASE_URL` (defaults to MaxMind GeoLite endpoint)

### Geolocation provider config
Set provider in runtime config:

```elixir
config :revstack, geolocation_provider: :maxmind
```

Use `:disabled` to turn geolocation lookups off.

### Fly commands

```bash
fly auth login
fly launch
fly deploy
fly logs
fly open
```

### Docker example

```bash
docker build -t revstack .
docker run -p 4000:4000 \
  -e SECRET_KEY_BASE="..." \
  -e DATABASE_URL="..." \
  -e PHX_SERVER=true \
  revstack
```

## Project structure

```text
lib/
  revstack/
    accounts/
    consulting/
    tracking/
    accounts.ex
    consulting.ex
    tracking.ex
    application.ex
    repo.ex
    repo_config.ex
    release.ex
    mailer.ex
  revstack_web/
    live/
      admin/
    controllers/
      auth_controller.ex
      resume_controller.ex
    plugs/
      visitor_tracking.ex
    components/
    live_user_auth.ex
    router.ex

test/
  revstack/
  revstack_web/
  support/
```

## CI

GitHub Actions workflow runs on pushes/PRs to `main` and executes compile + full tests.

## License

All rights reserved - RevenueLink Technologies LLC
