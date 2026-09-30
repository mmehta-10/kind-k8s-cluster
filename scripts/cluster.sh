#!/bin/bash

# set -ex

# github: https://github.com/kubernetes-sigs/kind
ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

# Uncomment or modify the following line to change the provider, or unset to use default (docker)
# export KIND_EXPERIMENTAL_PROVIDER=podman

usage() {
  echo "Commands:"
  echo "  $0 install"
  echo "  $0 create"
  echo "  $0 list"
  echo "  $0 delete"
  echo "  $0 install-apps"
  echo "  $0 install-traefik"
  echo "  $0 install-omniroute"
  echo "  $0 install-hermes"
  echo "  $0 install-argocd"
  echo "  $0 install-1password"
  echo "  $0 export-hermes-portable [destination-directory]"
  echo "  $0 configure-integrations"
  exit 1
}

case $1 in
install)
  # Install kind-cluster
  # Detect OS and architecture
  OS=$(uname -s | tr '[:upper:]' '[:lower:]')
  ARCH=$(uname -m)

  # Convert architecture names to match Kind's naming
  case ${ARCH} in
  x86_64)
    ARCH="amd64"
    ;;
  aarch64)
    ARCH="arm64"
    ;;
  armv7l)
    ARCH="arm"
    ;;
  esac

  # Download appropriate Kind version
  curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.20.0/kind-${OS}-${ARCH}"
  chmod +x ./kind
  sudo mv ./kind /usr/local/bin/kind || mv ./kind "${HOME}/bin/kind"
  ;;

create)
  kind create cluster \
    --name kind \
    --kubeconfig ${HOME}/.kube/config-kind \
    --config "${ROOT_DIR}/clusters/local/kind-config.yaml"
  ;;

list)
  kind get clusters
  ;;

delete)
  kind delete clusters kind
  ;;

install-apps)
  kubectl apply -f "${ROOT_DIR}/argocd/applicationset.yaml"
  ;;

install-traefik)
  helm repo add traefik https://helm.traefik.io/traefik --force-update
  helm repo update
  helm upgrade --install traefik traefik/traefik \
    -n traefik --create-namespace \
    --kubeconfig "${HOME}/.kube/config-kind" \
    -f "${ROOT_DIR}/traefik.values.yaml"
  ;;

install-omniroute)
  kubectl apply -f "${ROOT_DIR}/apps/omniroute/omniroute-deployment.yaml"
  ;;

install-hermes)
  kubectl apply -f "${ROOT_DIR}/apps/hermes/hermes-deployment.yaml"
  ;;

install-1password)
  : "${OP_SERVICE_ACCOUNT_TOKEN:?Set OP_SERVICE_ACCOUNT_TOKEN to your 1Password Service Account token (ops_...)}"

  helm repo add 1password https://1password.github.io/connect-helm-charts/ --force-update
  
  helm repo update
  helm upgrade --install onepassword 1password/connect \
    -n 1password --create-namespace \
    --set connect.create=false \
    --set operator.create=true \
    --set operator.authMethod=service-account \
    --set operator.serviceAccountToken.value="${OP_SERVICE_ACCOUNT_TOKEN}" \
    --set operator.autoRestart=true

  kubectl apply -f "${ROOT_DIR}/1password/items.yaml"
  ;;

install-argocd)
  helm repo add argo https://argoproj.github.io/argo-helm
  helm repo update
  helm upgrade --install argocd argo/argo-cd --namespace argocd -f "${ROOT_DIR}/argocd/values.yaml" --create-namespace
  ;;

export-hermes-portable)
  HERMES_EXPORT_TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  HERMES_EXPORT_DIR=${2:-"${HOME}/hermes-portable-export-${HERMES_EXPORT_TIMESTAMP}"}
  HERMES_EXPORT_ROOT="${HERMES_EXPORT_DIR}/.hermes"

  if [[ -e "${HERMES_EXPORT_DIR}" && ! -d "${HERMES_EXPORT_DIR}" ]]; then
    echo "Destination exists but is not a directory: ${HERMES_EXPORT_DIR}" >&2
    exit 1
  fi

  if ! command -v rsync >/dev/null 2>&1; then
    echo "rsync is required for incremental Hermes exports" >&2
    exit 1
  fi

  HERMES_EXPORT_POD=$(kubectl -n hermes get pod \
    -l app=hermes-agent \
    --field-selector=status.phase=Running \
    -o jsonpath='{.items[0].metadata.name}')
  if [[ -z "${HERMES_EXPORT_POD}" ]]; then
    echo "No running Hermes pod found in namespace hermes" >&2
    exit 1
  fi

  if ! HERMES_EXPORT_STAGE=$(mktemp -d); then
    echo "Could not create a temporary directory for the Hermes export" >&2
    exit 1
  fi
  HERMES_EXPORT_STAGE_ROOT="${HERMES_EXPORT_STAGE}/.hermes"
  trap 'rm -rf -- "${HERMES_EXPORT_STAGE}"' EXIT
  mkdir -p "${HERMES_EXPORT_ROOT}" "${HERMES_EXPORT_STAGE_ROOT}"
  chmod 700 "${HERMES_EXPORT_ROOT}" "${HERMES_EXPORT_STAGE_ROOT}"

  set -o pipefail
  kubectl -n hermes exec "${HERMES_EXPORT_POD}" -c hermes -- sh -ceu '
    cd /opt/data
    export_list=/tmp/hermes-portable-export.$$
    trap '\''rm -f "${export_list}"'\'' EXIT
    : >"${export_list}"

    for path in \
      config.yaml profile.yaml active_profile SOUL.md \
      context_length_cache.yaml slack-manifest.json shell-hooks-allowlist.json \
      skills skins desktop-plugins tui-widgets pets hooks scripts plans memories
    do
      if [ -e "${path}" ] || [ -L "${path}" ]; then
        printf '\''%s\n'\'' "${path}" >>"${export_list}"
      fi
    done

    if [ -d profiles ]; then
      for profile in profiles/*; do
        [ -d "${profile}" ] || continue
        for leaf in \
          config.yaml profile.yaml SOUL.md context_length_cache.yaml \
          slack-manifest.json shell-hooks-allowlist.json \
          skills skins desktop-plugins tui-widgets pets hooks scripts plans memories
        do
          path="${profile}/${leaf}"
          if [ -e "${path}" ] || [ -L "${path}" ]; then
            printf '\''%s\n'\'' "${path}" >>"${export_list}"
          fi
        done
      done
    fi

    test -s "${export_list}"
    tar --ignore-case -cf - \
      --exclude='\''.env'\'' \
      --exclude='\''.env.*'\'' \
      --exclude='\''*/.env'\'' \
      --exclude='\''*/.env.*'\'' \
      --exclude='\''*auth.json'\'' \
      --exclude='\''*.anthropic_oauth.json'\'' \
      --exclude='\''*google_token.json'\'' \
      --exclude='\''*token*'\'' \
      --exclude='\''*credential*'\'' \
      --exclude='\''*secret*'\'' \
      --exclude='\''*password*'\'' \
      --exclude='\''*private*key*'\'' \
      --exclude='\''*.key'\'' \
      --exclude='\''*.pem'\'' \
      --exclude='\''*.p12'\'' \
      --exclude='\''*.pfx'\'' \
      --exclude='\''mcp-tokens'\'' \
      --exclude='\''credentials'\'' \
      --exclude='\''pairing'\'' \
      --exclude='\''node_modules'\'' \
      --exclude='\''.venv'\'' \
      --exclude='\''venv'\'' \
      --exclude='\''site-packages'\'' \
      --exclude='\''__pycache__'\'' \
      --exclude='\''*.pyc'\'' \
      --exclude='\''*.pyo'\'' \
      --exclude='\''*.lock'\'' \
      --exclude='\''*.pid'\'' \
      --exclude='\''*.sock'\'' \
      --exclude='\''*.log'\'' \
      --exclude='\''*.db'\'' \
      --exclude='\''*.db-*'\'' \
      --exclude='\''*.sqlite'\'' \
      --exclude='\''*.sqlite3'\'' \
      --exclude='\''cache'\'' \
      --exclude='\''runtime'\'' \
      --exclude='\''state'\'' \
      --exclude='\''sessions'\'' \
      --exclude='\''sandboxes'\'' \
      --exclude='\''backups'\'' \
      --exclude='\''browser-profile*'\'' \
      --exclude='\''skills/.usage.json'\'' \
      --exclude='\''skills/.usage.json.lock'\'' \
      --exclude='\''skills/.hub'\'' \
      --exclude='\''skills/.curator_backups'\'' \
      -T "${export_list}"
  ' | tar -xf - -C "${HERMES_EXPORT_STAGE_ROOT}"
  HERMES_EXPORT_STATUS=$?
  if [[ "${HERMES_EXPORT_STATUS}" -ne 0 ]]; then
    echo "Hermes export failed; the existing destination was not changed" >&2
    exit "${HERMES_EXPORT_STATUS}"
  fi

  if ! HERMES_SYNC_OUTPUT=$(rsync \
      -rlt \
      --checksum \
      --delete \
      --itemize-changes \
      "${HERMES_EXPORT_STAGE_ROOT}/" \
      "${HERMES_EXPORT_ROOT}/"); then
    echo "Could not incrementally update ${HERMES_EXPORT_ROOT}" >&2
    exit 1
  fi

  if [[ -n "${HERMES_SYNC_OUTPUT}" ]]; then
    echo "Hermes portable changes:"
    printf '%s\n' "${HERMES_SYNC_OUTPUT}"
  else
    echo "No portable Hermes changes detected."
  fi

  chmod -R u+rwX,go-rwx "${HERMES_EXPORT_ROOT}"

  HERMES_REVIEW_FILE="${HERMES_EXPORT_DIR}/REVIEW_BEFORE_COMMIT.txt"
  HERMES_SECRET_PATTERN='(api[_-]?key|access[_-]?token|refresh[_-]?token|app[_-]?token|bot[_-]?token|signing[_-]?secret|client[_-]?secret|password|passwd|private[_-]?key|credential|webhook[_-]?url|session[_-]?key|cookie|dsn)[[:space:]]*[:=]'
  if command -v rg >/dev/null 2>&1; then
    rg -l --hidden -i "${HERMES_SECRET_PATTERN}" "${HERMES_EXPORT_ROOT}" \
      >"${HERMES_REVIEW_FILE}" || true
  else
    grep -RIlE "${HERMES_SECRET_PATTERN}" "${HERMES_EXPORT_ROOT}" \
      >"${HERMES_REVIEW_FILE}" || true
  fi
  chmod 600 "${HERMES_REVIEW_FILE}"

  HERMES_EXPORTED_FILES=$(find "${HERMES_EXPORT_ROOT}" -type f | wc -l | tr -d ' ')
  HERMES_REVIEW_FILES=$(wc -l <"${HERMES_REVIEW_FILE}" | tr -d ' ')
  echo "Exported ${HERMES_EXPORTED_FILES} portable Hermes files to ${HERMES_EXPORT_ROOT}"
  if [[ "${HERMES_REVIEW_FILES}" -gt 0 ]]; then
    echo "Review ${HERMES_REVIEW_FILES} potentially sensitive files listed in ${HERMES_REVIEW_FILE} before adding to chezmoi."
  else
    rm -f "${HERMES_REVIEW_FILE}"
    echo "No credential-shaped assignments found by the basic content scan."
  fi
  ;;

configure-integrations)
  : "${OMNIROUTE_API_KEY:?Set OMNIROUTE_API_KEY to an OmniRoute endpoint key}"
  : "${OMNIROUTE_JWT_SECRET:?Set OMNIROUTE_JWT_SECRET to 32+ random bytes}"
  : "${OMNIROUTE_API_KEY_SECRET:?Set OMNIROUTE_API_KEY_SECRET to 32 random bytes as hex}"
  : "${HERMES_API_KEY:?Set HERMES_API_KEY to a random value of at least 8 characters}"
  : "${HERMES_DASHBOARD_PASSWORD:?Set HERMES_DASHBOARD_PASSWORD}"
  : "${HERMES_DASHBOARD_SIGNING_SECRET:?Set HERMES_DASHBOARD_SIGNING_SECRET to 32+ random bytes}"

  kubectl create namespace hermes --dry-run=client -o yaml |
    kubectl apply -f -
  kubectl create namespace omniroute --dry-run=client -o yaml |
    kubectl apply -f -

  kubectl -n omniroute create secret generic omniroute-auth \
    --from-literal=jwt-secret="${OMNIROUTE_JWT_SECRET}" \
    --from-literal=api-key-secret="${OMNIROUTE_API_KEY_SECRET}" \
    --from-literal=inference-api-key="${OMNIROUTE_API_KEY}" \
    --dry-run=client -o yaml |
    kubectl apply -f -

  kubectl -n hermes create secret generic hermes-integrations \
    --from-literal=omniroute-api-key="${OMNIROUTE_API_KEY}" \
    --from-literal=hermes-api-key="${HERMES_API_KEY}" \
    --dry-run=client -o yaml |
    kubectl apply -f -

  kubectl -n hermes create secret generic hermes-dashboard-auth \
    --from-literal=username=admin \
    --from-literal=password="${HERMES_DASHBOARD_PASSWORD}" \
    --from-literal=signing-secret="${HERMES_DASHBOARD_SIGNING_SECRET}" \
    --dry-run=client -o yaml |
    kubectl apply -f -
  ;;

*)
  usage
  ;;
esac
