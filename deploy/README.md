# Revstack VPS Deployment (Ansible)

Deploy Revstack to any Ubuntu VPS using Ansible. Replaces Fly.io with a self-managed setup.

## Architecture

- **Nginx** — reverse proxy with SSL termination (Let's Encrypt)
- **Docker** — runs the Phoenix release (reuses existing `Dockerfile`)
- **PostgreSQL** — native install on the VPS
- **UFW + fail2ban** — firewall and brute-force protection

## Prerequisites

- A VPS running Ubuntu 22.04+ with SSH access
- Python 3 on the VPS (usually pre-installed)
- Locally: `ansible` (`pip install ansible`)

## Quick Start

```bash
cd deploy

# 1. Configure your VPS
cp inventory.ini.example inventory.ini
# Edit inventory.ini — set your VPS IP and SSH key path

# 2. Configure your app
# Edit group_vars/all.yml — set domain, git repo, certbot email

# 3. Generate secrets
./deploy.sh secrets

# 4. Provision VPS + deploy app
./deploy.sh full
```

## Commands

| Command | Description |
|---------|-------------|
| `./deploy.sh setup` | Provision VPS (Docker, PostgreSQL, Nginx, SSL) |
| `./deploy.sh deploy` | Deploy/update the application |
| `./deploy.sh full` | Setup + deploy (default) |
| `./deploy.sh secrets` | Generate secrets and create Ansible vault |
| `./deploy.sh logs` | Tail application logs |
| `./deploy.sh status` | Check container and app status |
| `./deploy.sh ssh` | SSH into the VPS |

## What Gets Deployed

1. **Base setup** — packages, firewall (UFW), fail2ban, deploy user
2. **Docker** — Docker Engine + Compose plugin
3. **PostgreSQL** — native install, creates database and user
4. **Nginx** — reverse proxy config, Let's Encrypt SSL via certbot
5. **App** — syncs source, builds Docker image on server, runs migrations, starts app

## Environment Variables

Secrets are loaded from files under `group_vars/web/`. The current helper writes `group_vars/web/secrets.yml`, which is gitignored. You can optionally encrypt that file with Ansible Vault. See [.env.production.example](.env.production.example) for the full list.

Required:
- `DATABASE_URL` — PostgreSQL connection string
- `SECRET_KEY_BASE` — Phoenix secret key
- `TOKEN_SIGNING_SECRET` — Auth token signing
- `PHX_HOST` — Your domain name
- `ADMIN_EMAIL` / `ADMIN_PASSWORD` — Admin credentials

## SSL

SSL certificates are automatically provisioned via Let's Encrypt/certbot. Auto-renewal runs on the 1st and 15th of each month.

## Files

```
deploy/
├── ansible.cfg                    # Ansible configuration
├── deploy.sh                      # CLI entry point
├── inventory.ini.example          # VPS connection template
├── playbook.yml                   # Main playbook
├── group_vars/
│   └── all.yml                    # Variables (edit this)
└── roles/
    ├── base/tasks/main.yml        # OS packages, firewall, users
    ├── docker/
    │   ├── tasks/main.yml         # Docker Engine install
    │   └── handlers/main.yml
    ├── postgres/
    │   ├── tasks/main.yml         # PostgreSQL setup
    │   └── handlers/main.yml
    ├── nginx/
    │   ├── tasks/main.yml         # Nginx + certbot
    │   ├── handlers/main.yml
    │   └── templates/
    │       ├── revstack-http.conf.j2   # Pre-SSL config
    │       └── revstack-ssl.conf.j2    # Full SSL config
    └── app/
        ├── tasks/main.yml         # Build + deploy app
        └── templates/
            ├── docker-compose.yml.j2
            └── env.production.j2
```
