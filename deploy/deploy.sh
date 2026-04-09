#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

usage() {
    echo -e "${GREEN}Revstack VPS Deployment${NC}"
    echo ""
    echo "Usage: $0 [command]"
    echo ""
    echo "Commands:"
    echo "  setup       Initial VPS setup (installs Docker, PostgreSQL, Nginx, SSL)"
    echo "  deploy      Deploy/update the application"
    echo "  full        Run setup + deploy (default)"
    echo "  secrets     Generate secrets in group_vars/web/secrets.yml"
    echo "  rollback    Not supported by the current on-server build flow"
    echo "  logs        Tail application logs on server"
    echo "  status      Check app status on server"
    echo "  ssh         SSH into the VPS"
    echo ""
    echo "First-time setup:"
    echo "  1. cp inventory.ini.example inventory.ini"
    echo "  2. Edit inventory.ini with your VPS IP"
    echo "  3. Edit group_vars/all.yml with your domain and settings"
    echo "  4. Run: $0 secrets    (generates secrets)"
    echo "  5. Run: $0 full       (provisions + deploys)"
    echo ""
}

get_vault_args() {
    if command -v rg &>/dev/null && rg -l '^\$ANSIBLE_VAULT;' group_vars &>/dev/null; then
        echo "--ask-vault-pass"
    fi
}

check_prereqs() {
    if ! command -v ansible-playbook &>/dev/null; then
        echo -e "${RED}Error: ansible is not installed.${NC}"
        echo "Install it: pip install ansible"
        exit 1
    fi

    if [[ ! -f inventory.ini ]]; then
        echo -e "${RED}Error: inventory.ini not found.${NC}"
        echo "Run: cp inventory.ini.example inventory.ini"
        echo "Then edit it with your VPS IP address."
        exit 1
    fi
}

get_inventory_host_line() {
    awk '
        /^\[web\]$/ { in_web=1; next }
        /^\[/ && in_web { exit }
        in_web && $0 !~ /^#/ && NF { print; exit }
    ' inventory.ini
}

expand_path() {
    local path="$1"
    if [[ "$path" == ~/* ]]; then
        printf '%s\n' "${HOME}/${path#~/}"
    else
        printf '%s\n' "$path"
    fi
}

load_ssh_config() {
    local host_line token

    host_line="$(get_inventory_host_line)"

    if [[ -z "$host_line" ]]; then
        echo -e "${RED}Error: could not find a host entry under [web] in inventory.ini.${NC}" >&2
        exit 1
    fi

    SSH_HOST="${host_line%% *}"
    SSH_USER=""
    SSH_KEY=""
    SSH_PORT=""

    for token in $host_line; do
        case "$token" in
            ansible_user=*)
                SSH_USER="${token#ansible_user=}"
                ;;
            ansible_ssh_private_key_file=*)
                SSH_KEY="$(expand_path "${token#ansible_ssh_private_key_file=}")"
                ;;
            ansible_port=*)
                SSH_PORT="${token#ansible_port=}"
                ;;
        esac
    done

    if [[ -z "$SSH_USER" ]]; then
        SSH_USER="deploy"
    fi
}

run_remote() {
    local remote_cmd="${1-}"
    local -a ssh_cmd

    load_ssh_config

    ssh_cmd=(ssh)

    if [[ -n "$SSH_KEY" ]]; then
        ssh_cmd+=( -i "$SSH_KEY" )
    fi

    if [[ -n "$SSH_PORT" ]]; then
        ssh_cmd+=( -p "$SSH_PORT" )
    fi

    ssh_cmd+=( "${SSH_USER}@${SSH_HOST}" )

    if [[ -n "$remote_cmd" ]]; then
        ssh_cmd+=( "$remote_cmd" )
    fi

    "${ssh_cmd[@]}"
}

generate_secrets() {
    echo -e "${YELLOW}Generating secrets...${NC}"

    if ! command -v openssl &>/dev/null; then
        echo -e "${RED}Error: openssl is required to generate secrets${NC}"
        exit 1
    fi

    SECRET_KEY_BASE=$(openssl rand -base64 48 | tr -d '\n')
    TOKEN_SIGNING_SECRET=$(openssl rand -base64 48 | tr -d '\n')
    DB_PASSWORD=$(openssl rand -base64 32 | tr -d '\n/+=')

    echo -e "${GREEN}Generated secrets:${NC}"
    echo ""
    echo "SECRET_KEY_BASE:      ${SECRET_KEY_BASE}"
    echo "TOKEN_SIGNING_SECRET: ${TOKEN_SIGNING_SECRET}"
    echo "DB_PASSWORD:          ${DB_PASSWORD}"
    echo ""

    mkdir -p group_vars/web
    cat > group_vars/web/secrets.yml <<EOF
---
vault_secret_key_base: "${SECRET_KEY_BASE}"
vault_token_signing_secret: "${TOKEN_SIGNING_SECRET}"
vault_db_password: "${DB_PASSWORD}"
vault_admin_email: "admin@example.com"
vault_admin_password: "$(openssl rand -base64 16 | tr -d '\n/+=')"
EOF

    echo -e "${GREEN}Secrets written to group_vars/web/secrets.yml${NC}"
    echo "This file is gitignored."

    if command -v ansible-vault &>/dev/null; then
        echo "If you want to encrypt it: ansible-vault encrypt group_vars/web/secrets.yml"
        echo "To edit later: ansible-vault edit group_vars/web/secrets.yml"
    fi
}

cmd_setup() {
    check_prereqs
    echo -e "${GREEN}Setting up VPS infrastructure...${NC}"

    VAULT_ARGS="$(get_vault_args)"

    ansible-playbook playbook.yml --tags setup $VAULT_ARGS "$@"
}

cmd_deploy() {
    check_prereqs
    echo -e "${GREEN}Deploying Revstack...${NC}"

    VAULT_ARGS="$(get_vault_args)"

    ansible-playbook playbook.yml --tags deploy $VAULT_ARGS "$@"
}

cmd_full() {
    check_prereqs
    echo -e "${GREEN}Running full setup + deploy...${NC}"

    VAULT_ARGS="$(get_vault_args)"

    ansible-playbook playbook.yml $VAULT_ARGS "$@"
}

cmd_rollback() {
    echo -e "${RED}Rollback is not implemented in the current build-on-server workflow.${NC}"
    echo "Redeploy a known-good commit instead:"
    echo "  git checkout <good-commit-or-tag>"
    echo "  cd deploy && ./deploy.sh deploy"
    exit 1
}

cmd_logs() {
    check_prereqs
    run_remote "cd /opt/revstack && docker compose logs -f --tail=100 app"
}

cmd_status() {
    check_prereqs
    echo -e "${GREEN}Container status:${NC}"
    run_remote "cd /opt/revstack && docker compose ps"
    echo ""
    echo -e "${GREEN}Recent logs:${NC}"
    run_remote "cd /opt/revstack && docker compose logs --tail=20 app"
}

cmd_ssh() {
    check_prereqs
    run_remote ''
}

# Main
case "${1:-full}" in
    setup)   shift; cmd_setup "$@" ;;
    deploy)  shift; cmd_deploy "$@" ;;
    full)    shift 2>/dev/null || true; cmd_full "$@" ;;
    secrets) generate_secrets ;;
    rollback) cmd_rollback ;;
    logs)    cmd_logs ;;
    status)  cmd_status ;;
    ssh)     cmd_ssh ;;
    -h|--help|help) usage ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        usage
        exit 1
        ;;
esac
