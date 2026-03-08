# Revstack

A Phoenix LiveView technical profile website, currently serving as a high-end recruiter-facing showcase. Built for RevenueLink Technologies LLC and ready to serve as the company website when needed.

**Live Site**: [https://revstack.fly.dev/](https://revstack.fly.dev/)

## Features

### Public Pages
- **Home** (`/`) — High-end technical profile featuring expertise, leadership experience, and professional interests
- Additional consulting pages (About, Services, Contact, Estimate, Privacy Policy) are implemented but currently hidden from navigation

### Admin Features
- **Ash Admin** (`/admin`) — Admin dashboard for managing leads and estimate requests (magic link authentication)
- Lead and EstimateRequest resources with status tracking and filtering

### Technical Stack
- **Phoenix 1.8** with LiveView
- **Ash Framework** + **AshPostgres** for domain modeling and data persistence
- **AshAuthentication** with magic link sign-in
- **AshAdmin** for admin dashboard
- **Tailwind CSS v4** + **daisyUI** for styling
- **PostgreSQL** database

### Data Models
- **Lead** — Contact form submissions (name, email, company, message, contact method, phone, status)
- **EstimateRequest** — Project estimate requests (name, email, project type, budget range, timeline, summary, internal size tag)

Both models include honeypot anti-spam, email validation, and role-based authorization (public create, admin read/update/destroy).

## Getting Started

### Prerequisites
- Elixir ~> 1.19.5
- PostgreSQL 16+

### Setup

1. Install dependencies and set up the database:
```bash
mix setup
```

2. Start the development server:
```bash
mix phx.server
```

3. Visit [`localhost:4000`](http://localhost:4000) in your browser.

The site is fully functional immediately — forms submit to the database, and you can access the Ash Admin dashboard at `/admin` with magic link authentication.

## Development

- **Run tests**: `mix test`
- **Format code**: `mix format`
- **Check for issues**: `mix precommit` (compile with warnings as errors, format check, test)
- **Generate migrations**: `mix ash.codegen <name>`

## Continuous Integration

This repository includes a GitHub Actions workflow at `.github/workflows/ci.yml`.

It runs when code is pushed to `main` and when a pull request targets `main`.

The workflow:
- checks out the latest commit for the branch or pull request
- starts PostgreSQL 16 for the test environment
- installs Elixir 1.19.5 and Erlang/OTP 28.1
- runs `mix compile --warnings-as-errors`
- runs `mix test`

To require CI to pass before merge, configure GitHub branch protection for `main` and require the `Build and test` status check.

## Project Structure

```
lib/
  revstack/
    accounts/           # AshAuthentication User resource
    consulting/         # Lead and EstimateRequest resources
    consulting.ex       # Consulting domain
  revstack_web/
    live/               # LiveView pages (home, about, services, etc.)
    components/         # Reusable UI components and layouts
    router.ex           # Route definitions

config/                 # Environment configuration
priv/
  repo/
    migrations/         # Database migrations
```

## Deployment

For production deployment, follow [Phoenix deployment guides](https://hexdocs.pm/phoenix/deployment.html).

Key considerations:
- Set `SECRET_KEY_BASE` environment variable
- Configure `DATABASE_URL` for your PostgreSQL instance
- Set up email for magic link authentication (via Swoosh configuration)
- Configure domain/host in `config/runtime.exs`

## License

All rights reserved — RevenueLink Technologies LLC
