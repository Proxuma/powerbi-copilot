#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# Proxuma Dashboard Renderer — Azure Static Web App Deployment
#
# Deploys the Dashboard Renderer as a free Azure Static Web App.
# MSPs can host their own renderer at their own Azure tenant URL.
#
# Prerequisites:
#   - Azure CLI (az) installed and logged in
#   - An Azure subscription
#
# Usage:
#   ./deploy-static.sh                              # Interactive
#   ./deploy-static.sh --name mycompany-dashboards  # Non-interactive
# ---------------------------------------------------------------------------

set -euo pipefail

LOCATION="westeurope"
APP_NAME=""
RESOURCE_GROUP=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --name)           APP_NAME="$2"; shift 2 ;;
        --resource-group) RESOURCE_GROUP="$2"; shift 2 ;;
        --location)       LOCATION="$2"; shift 2 ;;
        *)                echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$APP_NAME" ]]; then
    read -rp "Static Web App name (e.g., mycompany-dashboards): " APP_NAME
fi
if [[ -z "$RESOURCE_GROUP" ]]; then
    RESOURCE_GROUP="${APP_NAME}-rg"
    read -rp "Resource group [$RESOURCE_GROUP]: " input
    RESOURCE_GROUP="${input:-$RESOURCE_GROUP}"
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo ""
echo "=== Deployment Summary ==="
echo "  App Name:        $APP_NAME"
echo "  Resource Group:  $RESOURCE_GROUP"
echo "  Location:        $LOCATION"
echo "  Source:           $REPO_ROOT"
echo ""
read -rp "Proceed? [Y/n] " confirm
if [[ "${confirm,,}" == "n" ]]; then
    echo "Aborted."
    exit 0
fi

echo ""
echo "[1/3] Creating resource group..."
az group create --name "$RESOURCE_GROUP" --location "$LOCATION" --output none

echo "[2/3] Creating Static Web App (Free tier)..."
az staticwebapp create \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku Free \
    --output none

echo "[3/3] Deploying files..."
# Get deployment token
DEPLOY_TOKEN=$(az staticwebapp secrets list \
    --name "$APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "properties.apiKey" -o tsv)

# Build deploy package — copy only what's needed
TEMP_DIR=$(mktemp -d)
cp "$REPO_ROOT/index.html" "$TEMP_DIR/" 2>/dev/null || true
cp "$REPO_ROOT/templates/dashboard-renderer.html" "$TEMP_DIR/"
cp -r "$REPO_ROOT/templates/configs" "$TEMP_DIR/configs" 2>/dev/null || true
cp "$SCRIPT_DIR/staticwebapp.config.json" "$TEMP_DIR/"

# Deploy using SWA CLI (install if needed)
if ! command -v swa &>/dev/null; then
    echo "    Installing SWA CLI..."
    npm install -g @azure/static-web-apps-cli 2>/dev/null
fi

swa deploy "$TEMP_DIR" \
    --deployment-token "$DEPLOY_TOKEN" \
    --env production

rm -rf "$TEMP_DIR"

APP_URL="https://$(az staticwebapp show --name "$APP_NAME" --resource-group "$RESOURCE_GROUP" --query "defaultHostname" -o tsv)"

echo ""
echo "=== Deployment Complete ==="
echo ""
echo "  Dashboard Renderer:  ${APP_URL}/dashboard-renderer.html"
echo "  Template Configs:    ${APP_URL}/configs/"
echo ""
echo "=== Pricing ==="
echo ""
echo "  Azure Static Web Apps Free tier:"
echo "    - 100 GB bandwidth/month"
echo "    - 2 custom domains"
echo "    - Free SSL certificates"
echo "    - No monthly cost"
echo ""
echo "=== Next Steps ==="
echo ""
echo "  1. Open ${APP_URL}/dashboard-renderer.html"
echo "  2. Paste DASH_CONFIG + DATA JSON from your Copilot agent"
echo "  3. (Optional) Add a custom domain in Azure Portal"
echo ""
