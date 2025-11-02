#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# Filename: scaleway_macmini_automation.sh
# Purpose : Provision or reuse a Scaleway Apple Silicon macOS 26 (Tahoe) Mac mini
# Author  : Derek
# Version : v1.0.0 - 2025-11-03
# License : © HyperSec Pty Ltd. All rights reserved.
# -----------------------------------------------------------------------------
set -o errexit
set -o nounset
set -o pipefail

# --- Configuration ------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
OUTPUT_ENV="${SCRIPT_DIR}/macmini-connection.env"
NAME="hypersec-test-macmini"
ZONE="fr-par-3"        # Current zone for Apple Silicon M1
TYPE="M1-M"            # macOS 26 Tahoe variant (as of Scaleway API)
API_URL="https://api.scaleway.com/apple-silicon/v1alpha1/zones/${ZONE}/servers"

# --- Load credentials ---------------------------------------------------------
if [[ ! -f "${ENV_FILE}" ]]; then
  echo "Missing .env with SCALEWAY_ACCESS_KEY_ID, SCALEWAY_ACCESS_KEY_SECRET, SCALEWAY_PROJECT_ID"
  exit 1
fi
# shellcheck disable=SC1090
source "${ENV_FILE}"

# --- Helper: Auth header ------------------------------------------------------
AUTH_HEADER="X-Auth-Token: ${SCALEWAY_ACCESS_KEY_SECRET}"

# --- Check existing server ----------------------------------------------------
echo "Checking for existing Mac mini named '${NAME}'..."
EXISTING_JSON=$(curl -s -H "${AUTH_HEADER}" "${API_URL}")
SERVER_ID=$(echo "${EXISTING_JSON}" | jq -r --arg NAME "${NAME}" '.servers[] | select(.name==$NAME) | .id // empty')

if [[ -n "${SERVER_ID}" ]]; then
  echo "Found existing Mac mini: ${SERVER_ID} — reusing."
else
  echo "No existing Mac mini found. Creating new instance..."
  CREATE_JSON=$(jq -n \
    --arg name "${NAME}" \
    --arg project_id "${SCALEWAY_PROJECT_ID}" \
    --arg type "${TYPE}" \
    '{name:$name, project_id:$project_id, type:$type}')

  RESPONSE=$(curl -s -X POST -H "${AUTH_HEADER}" -H "Content-Type: application/json" \
    -d "${CREATE_JSON}" "${API_URL}")

  SERVER_ID=$(echo "${RESPONSE}" | jq -r '.server.id')
  if [[ -z "${SERVER_ID}" || "${SERVER_ID}" == "null" ]]; then
    echo "Failed to create Mac mini:"
    echo "${RESPONSE}" | jq
    exit 1
  fi
  echo "Created new Mac mini: ${SERVER_ID}"
fi

# --- Poll until ready ---------------------------------------------------------
echo "Waiting for server ${SERVER_ID} to become ready..."
for i in {1..60}; do
  STATUS_JSON=$(curl -s -H "${AUTH_HEADER}" "${API_URL}/${SERVER_ID}")
  STATUS=$(echo "${STATUS_JSON}" | jq -r '.server.status')
  if [[ "${STATUS}" == "ready" ]]; then
    echo "Server is ready."
    break
  fi
  echo "Status: ${STATUS} (retry ${i}/60)"
  sleep 20
done

# --- Gather connection info ---------------------------------------------------
INFO_JSON=$(curl -s -H "${AUTH_HEADER}" "${API_URL}/${SERVER_ID}")
USERNAME=$(echo "${INFO_JSON}" | jq -r '.server.credentials.username')
PASSWORD=$(echo "${INFO_JSON}" | jq -r '.server.credentials.password')
PUBLIC_IP=$(echo "${INFO_JSON}" | jq -r '.server.public_ip.address')
VNC_PORT=$(echo "${INFO_JSON}" | jq -r '.server.vnc_port')
SSH_CMD="ssh ${USERNAME}@${PUBLIC_IP}"
DELETABLE_FROM=$(echo "${INFO_JSON}" | jq -r '.server.deletable_at')

# --- Write connection env file ------------------------------------------------
cat > "${OUTPUT_ENV}" <<EOF
# Generated $(date -u)
MACMINI_SSH_COMMAND="${SSH_CMD}"
MACMINI_USERNAME="${USERNAME}"
MACMINI_PASSWORD="${PASSWORD}"
MACMINI_ID="${SERVER_ID}"
MACMINI_PUBLIC_IP="${PUBLIC_IP}"
MACMINI_VNC_PORT="${VNC_PORT}"
MACMINI_DELETABLE_AT="${DELETABLE_FROM}"
EOF

echo "Connection info written to: ${OUTPUT_ENV}"

# --- Schedule deletion after 24 hours ----------------------------------------
DELETE_SCRIPT="${SCRIPT_DIR}/delete_macmini_${SERVER_ID}.sh"
cat > "${DELETE_SCRIPT}" <<EOF
#!/usr/bin/env bash
set -o errexit
set -o nounset
set -o pipefail
echo "Deleting Scaleway Mac mini ${SERVER_ID}..."
curl -s -X DELETE -H "${AUTH_HEADER}" "${API_URL}/${SERVER_ID}" && echo "Deleted."
EOF
chmod +x "${DELETE_SCRIPT}"

echo "Scheduling auto-delete in 24 hours..."
at now + 24 hours <<< "${DELETE_SCRIPT}"

echo "✅ Done. Mac mini ready for use."
echo "   SSH: ${SSH_CMD}"
echo "   Username: ${USERNAME}"
echo "   Password: ${PASSWORD}"
echo "   VNC: ${PUBLIC_IP}:${VNC_PORT}"
echo "   Will auto-delete after 24h."
