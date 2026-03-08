# Revstack

A Phoenix LiveView consulting website for RevenueLink Technologies LLC, featuring Elixir & Erlang consulting services, client engagement forms, and a full-featured admin panel for managing leads and project estimates.

**Live Site**: [https://revstack.fly.dev/](https://revstack.fly.dev/)

## Features

### Public Pages
- **Home** (`/`, `/whoami`) — Technical profile and consulting services showcase
- **About** (`/about`) — Company background and expertise
- **Services** (`/services`) — Consulting service offerings
- **Estimate** (`/estimate`) — Project estimate request form
- **Contact** (`/contact`) — Contact form for general inquiries
- **Privacy** (`/privacy`) — Privacy policy
- **Thanks** (`/thanks`) — Thank you page after form submissions

### Admin Dashboard
- **Dashboard** (`/admin`) — Main dashboard with summary cards and quick navigation
- **Leads Management** (`/admin/leads`) — Full CRUD for contact form submissions
  - List view with status badges, filtering, and pagination
  - Detail view with contact history and status management
  - Status workflow: new → contacted → closed
- **Estimates Management** (`/admin/estimates`) — Full CRUD for project estimates
  - List view with project details and internal sizing
  - Detail view with complete project requirements
  - Status workflow: new → in_review → responded → closed
  - Internal size tagging: small, medium, large, unknown

### Authentication & Authorization
- **Password-based authentication** with email/password
- **Sign-in tokens** for passwordless magic link authentication
- **Password reset** with email-based token flow (24-hour validity)
- **Remember me** functionality for persistent sessions
- **Admin role** attribute on users for dashboard access
- **Policy-based authorization** via Ash.Policy.Authorizer
  - Public users can create leads and estimates
  - Only admin users can read, update, and delete records

### Technical Stack
- **Phoenix 1.8** with LiveView for real-time UI
- **Ash Framework 3.0** for domain modeling and business logic
- **AshPostgres 2.0** for data persistence
- **AshAuthentication 4.0** with password strategy
- **AshAuthentication.Phoenix 2.0** for LiveView auth flows
- **Tailwind CSS v4** + **daisyUI** for styling
- **PostgreSQL 16+** database
- **Bandit** web server
- **Swoosh** for transactional email (password resets, magic links)
- **Req** for HTTP requests

### Data Models

#### Lead
Contact form submissions with the following attributes:
- **Contact info**: name (required), email (required), company (optional), phone (optional)
- **Communication**: message (min 20 chars), preferred_contact_method (email/phone/either)
- **Tracking**: status (new/contacted/closed), source (default: "website")
- **Anti-spam**: honeypot field (must be empty)

Validations:
- Email format validation (`/^[^\s]+@[^\s]+\.[^\s]+$/`)
- Message minimum length (20 characters)
- Phone required when preferred contact method is "phone"
- Honeypot must be empty (anti-spam)

#### EstimateRequest
Project estimate requests with the following attributes:
- **Contact info**: name (required), email (required), company (optional)
- **Project details**:
  - project_type: phoenix_liveview_app, api_backend, erlang_service, modernization, devops_reliability, other
  - budget_range: under_5k, 5k_15k, 15k_50k, 50k_plus, unknown
  - timeline: asap, 1_2_months, 3_6_months, flexible
  - summary (min 30 chars), details (optional)
- **Admin tracking**: status (new/in_review/responded/closed), internal_size_tag (small/medium/large/unknown)
- **Source tracking**: source (default: "website")

Validations:
- Email format validation (`/^[^\s]+@[^\s]+\.[^\s]+$/`)
- Summary minimum length (30 characters)

#### User
Authentication and authorization resource:
- **Credentials**: email (unique), hashed_password
- **Authorization**: admin? (boolean, default: false)
- **Authentication**: supports password auth, sign-in tokens, password reset, remember me

### Development Tools
When running in development mode (`MIX_ENV=dev`):
- **Phoenix LiveDashboard** (`/dev/dashboard`) — Application metrics and debugging
- **Swoosh Mailbox** (`/dev/mailbox`) — Email preview for development
- **AshAdmin** (`/dev/ash-admin`) — Auto-generated admin interface for all Ash resources

## Getting Started

### Prerequisites
- **Elixir** 1.15 or later (tested with 1.19.5)
- **Erlang/OTP** 28+ (tested with 28.1)
- **PostgreSQL** 16+
- **Node.js** (for asset compilation)

### Setup

1. Install dependencies and set up the database:
```bash
mix setup
```

This runs:
- `mix deps.get` — Install Elixir dependencies
- `mix ash.setup` — Create database, run migrations, and seed data
- `mix assets.setup` — Install Tailwind CSS and esbuild
- `mix assets.build` — Compile CSS and JS assets, sync images

2. Start the development server:
```bash
mix phx.server
```

Or start it inside IEx for interactive debugging:
```bash
iex -S mix phx.server
```

3. Visit [`localhost:4000`](http://localhost:4000) in your browser.

The site is fully functional immediately — public forms submit to the database, and you can access the admin dashboard at `/admin` after creating an admin user.

### Creating an Admin User

In development, create an admin user via IEx:

```elixir
iex> Ash.create!(Revstack.Accounts.User, %{email: "admin@example.com", password: "SecurePassword123!", admin?: true})
```

Or using the database seeds file (`priv/repo/seeds.exs`) if configured.

## Development

### Common Commands

- **Run tests**: `mix test`
- **Run specific test file**: `mix test test/path/to/test.exs`
- **Run failed tests**: `mix test --failed`
- **Format code**: `mix format`
- **Pre-commit checks**: `mix precommit`
  - Compiles with `--warnings-as-errors`
  - Removes unused dependencies
  - Runs `mix format --check-formatted`
  - Runs full test suite

### Asset Management

- **Rebuild assets**: `mix assets.build`
- **Deploy assets** (minified): `mix assets.deploy`
- **Sync images** to static: `mix assets.sync`

### Database Management

- **Generate migration**: `mix ash.codegen <migration_name>`
- **Run migrations**: `mix ash.setup` or `mix ecto.migrate`
- **Reset database**: `mix ecto.reset`
- **Rollback migration**: `mix ecto.rollback`

### Development Tools

Access these tools while running the dev server:
- **LiveDashboard**: [http://localhost:4000/dev/dashboard](http://localhost:4000/dev/dashboard)
- **Email Preview**: [http://localhost:4000/dev/mailbox](http://localhost:4000/dev/mailbox)
- **AshAdmin**: [http://localhost:4000/dev/ash-admin](http://localhost:4000/dev/ash-admin)

## Continuous Integration

This repository includes a GitHub Actions workflow at [.github/workflows/ci.yml](.github/workflows/ci.yml).

### When It Runs
- On every push to `main`
- On every pull request targeting `main`

### What It Does
1. Checks out the latest commit
2. Starts PostgreSQL 16 service container
3. Sets up Elixir 1.19.5 and Erlang/OTP 28.1
4. Caches Mix dependencies and build artifacts
5. Installs Hex and Rebar
6. Fetches dependencies (`mix deps.get`)
7. Compiles with `--warnings-as-errors`
8. Runs full test suite (`mix test`)

### Configuration
- Runs on `ubuntu-latest` with a 20-minute timeout
- Uses concurrency groups to cancel duplicate pipeline runs
- Caches `deps/` and `_build/` directories for faster builds
- Sets `MIX_ENV=test` for the entire workflow

### Branch Protection
To require CI to pass before merging:
1. Go to repository Settings → Branches
2. Add a branch protection rule for `main`
3. Enable "Require status checks to pass before merging"
4. Select the "Build and test" check

## Testing

The project uses ExUnit for testing with Phoenix.LiveViewTest for LiveView integration tests.

### Test Structure
```
test/
  test_helper.exs           # Test configuration
  support/                  # Test utilities and fixtures
  revstack/                 # Context/resource tests
    consulting/
      lead_test.exs
      estimate_request_test.exs
    accounts/
      user_test.exs
  revstack_web/             # LiveView and controller tests
    live/
      home_live_test.exs
      contact_live_test.exs
      estimate_live_test.exs
      admin/
        dashboard_live_test.exs
        lead_live_test.exs
        estimate_request_live_test.exs
```

### Running Tests

```bash
# Run all tests
mix test

# Run a specific file
mix test test/revstack_web/live/contact_live_test.exs

# Run tests matching a pattern
mix test --only admin

# Run previously failed tests
mix test --failed

# Run with coverage (if configured)
mix test --cover
```

### Writing Tests

The project follows the guidelines from AGENTS.md:
- **CRITICAL**: Write tests for EVERY change
- **MANDATORY**: Run `mix test` after EVERY change
- Use `start_supervised!/1` for starting processes in tests
- Reference element IDs in LiveView templates for test assertions
- Use `Phoenix.LiveViewTest` functions like `render_submit/2`, `element/2`, `has_element?/2`
- Test outcomes, not implementation details

## Project Structure

```
lib/
  revstack/
    accounts/               # Authentication & user management
      user.ex              # User resource with password auth
      token.ex             # Authentication tokens
      user/                # User-related modules
    consulting/            # Business domain
      lead.ex              # Contact form submissions
      estimate_request.ex  # Project estimate requests
    accounts.ex            # Accounts domain module
    consulting.ex          # Consulting domain module
    application.ex         # Application supervisor
    mailer.ex              # Email delivery (Swoosh)
    release.ex             # Release tasks
    repo.ex                # Ecto repository
    secrets.ex             # Secret key base for tokens
  
  revstack_web/
    live/                  # LiveView pages
      home_live.ex         # (Aliased as WhoamiLive)
      whoami_live.ex       # Main home page
      about_live.ex
      services_live.ex
      estimate_live.ex     # Project estimate form
      contact_live.ex      # Contact form
      privacy_live.ex
      thanks_live.ex       # Form submission confirmation
      admin/               # Admin dashboard
        dashboard_live.ex  # Admin home
        lead_live/         # Lead management
          index.ex
          show.ex
        estimate_request_live/  # Estimate management
          index.ex
          show.ex
    components/            # Reusable UI components
      core_components.ex   # Phoenix built-in components
      layouts.ex           # App layout wrapper
    controllers/
      auth_controller.ex   # Authentication handlers
    live_user_auth.ex      # LiveView auth hooks
    auth_overrides.ex      # Custom auth UI overrides
    endpoint.ex            # Phoenix endpoint
    gettext.ex             # Internationalization
    router.ex              # Route definitions
    telemetry.ex           # Metrics and monitoring
  
  revstack_web.ex          # Web module definitions
  revstack.ex              # Main module definitions

config/                    # Environment configuration
  config.exs               # Base configuration
  dev.exs                  # Development config
  test.exs                 # Test config
  prod.exs                 # Production config (compile-time)
  runtime.exs              # Runtime config (all environments)

priv/
  repo/
    migrations/            # Database migrations (auto-generated)
    seeds.exs              # Seed data
  resource_snapshots/      # Ash resource snapshots
  static/                  # Static assets (compiled)
  gettext/                 # Translation files

assets/
  css/
    app.css                # Main stylesheet (Tailwind v4)
  js/
    app.js                 # Main JavaScript bundle
  images/                  # Source images
    admin_panel/           # Admin panel screenshots
  vendor/                  # Third-party JS
    daisyui.js
    heroicons.js
    topbar.js

test/
  support/                 # Test helpers
  revstack/                # Resource tests
  revstack_web/            # LiveView tests
```

## Deployment

The application is currently deployed to [Fly.io](https://fly.io) at [https://revstack.fly.dev/](https://revstack.fly.dev/).

### Environment Variables

Required for production:
- `SECRET_KEY_BASE` — Secret key for signing sessions and tokens (generate with `mix phx.gen.secret`)
- `DATABASE_URL` — PostgreSQL connection string (format: `ecto://USER:PASS@HOST/DATABASE`)
- `PHX_SERVER=true` — Start the Phoenix server on boot

Optional:
- `PORT` — HTTP port (default: 4000)
- `POOL_SIZE` — Database connection pool size (default: 10)
- `ECTO_IPV6` — Enable IPv6 for database connections (set to `true` or `1`)

### Email Configuration (Swoosh)

For password reset and magic link emails, configure a Swoosh adapter in `config/runtime.exs`:

```elixir
config :revstack, Revstack.Mailer,
  adapter: Swoosh.Adapters.Mailgun,
  api_key: System.get_env("MAILGUN_API_KEY"),
  domain: System.get_env("MAILGUN_DOMAIN")
```

Supported adapters: Mailgun, SendGrid, Postmark, Amazon SES, SMTP, and others.

### Fly.io Deployment

The project includes a `fly.toml` configuration file. To deploy:

```bash
# Install flyctl
brew install flyctl

# Login
fly auth login

# Launch app (first time)
fly launch

# Deploy changes
fly deploy

# View logs
fly logs

# Open app
fly open
```

### Docker Deployment

The project includes a `Dockerfile` for containerized deployment:

```bash
# Build image
docker build -t revstack .

# Run container
docker run -p 4000:4000 \
  -e SECRET_KEY_BASE="..." \
  -e DATABASE_URL="..." \
  -e PHX_SERVER=true \
  revstack
```

### Database Migrations

Migrations run automatically during `mix setup` for development. For production:

```bash
# Run pending migrations
mix ecto.migrate

# Or in a release
bin/revstack eval "Revstack.Release.migrate"
```

### Production Checklist

- [ ] Set `SECRET_KEY_BASE` environment variable
- [ ] Configure `DATABASE_URL` for PostgreSQL
- [ ] Set up email adapter (Swoosh) for password resets
- [ ] Configure host/domain in `config/runtime.exs`
- [ ] Enable SSL/TLS for database connections (uncomment `ssl: true` in runtime.exs)
- [ ] Create at least one admin user
- [ ] Set up monitoring and error tracking
- [ ] Configure backup strategy for PostgreSQL
- [ ] Set up CDN for static assets (optional)
- [ ] Enable rate limiting for public forms (optional)

### Creating Admin Users in Production

SSH into your production instance and run:

```bash
# Fly.io
fly ssh console
bin/revstack remote

# Then in IEx:
Ash.create!(Revstack.Accounts.User, %{
  email: "admin@example.com",
  password: "SecurePassword123!",
  admin?: true
})
```

Or use a Mix task/release command if you create one.

## Architecture & Design Decisions

### Why Ash Framework?

- **Domain-driven design**: Resources model business entities with actions, validations, and policies
- **Declarative authorization**: Policy-based access control at the resource level
- **AshAuthentication**: Built-in authentication strategies (password, magic links, tokens)
- **AshAdmin**: Auto-generated admin dashboards
- **Code generation**: Migrations generated from resource definitions
- **Composable**: Resources can reference and extend each other

### Why Phoenix LiveView?

- **Real-time UI**: WebSocket-based updates without JavaScript frameworks
- **Server-rendered**: No API layer needed for most features
- **Progressive enhancement**: Works with or without JavaScript
- **DX**: Elixir templates with full LiveView lifecycle

### Why Tailwind CSS v4 + daisyUI?

- **Utility-first**: Rapid UI development with utility classes
- **Tailwind v4**: New CSS-first configuration, faster builds
- **daisyUI**: Pre-built component classes for consistent design
- **Customizable**: Easy to extend and override styles

### Security Considerations

- **Password hashing**: bcrypt via Comeonin/Bcrypt Elixir
- **CSRF protection**: Phoenix built-in CSRF tokens
- **Honeypot fields**: Anti-spam bot protection on public forms
- **Policy authorization**: Resource-level access control via Ash.Policy
- **Secure sessions**: Signed and encrypted with SECRET_KEY_BASE
- **SQL injection prevention**: Ecto parameterized queries

## Contributing

This is a private project for RevenueLink Technologies LLC. Internal contributions should:

1. Create a feature branch from `main`
2. Make changes with tests (100% test coverage required)
3. Run `mix precommit` to validate
4. Submit a pull request
5. Wait for CI to pass
6. Merge after review

## License

All rights reserved — RevenueLink Technologies LLC
