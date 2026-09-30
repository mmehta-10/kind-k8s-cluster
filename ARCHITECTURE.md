# Hermes and OmniRoute Architecture

```text
Hermes Gateway :8080 (namespace: hermes)
       │
       ▼ OpenAI-compatible requests (via Kubernetes DNS)
OmniRoute :20128 (namespace: omniroute)
```

The workloads run in separate namespaces and communicate through Kubernetes DNS:
- Hermes: `hermes.hermes.svc.cluster.local:8080`
- OmniRoute: `omniroute.omniroute.svc.cluster.local:20128`

---

## Secret Management (1Password Service Accounts)

Secrets are sourced directly from 1Password using the official **1Password Kubernetes Operator** (SDK / Service Account path). 

- **No Connect sync servers** or credentials JSON files required.
- Authenticated via a single `OP_SERVICE_ACCOUNT_TOKEN` (`ops_...`).
- Managed via `OnePasswordItem` CRDs in `1password/items.yaml`.
- Automatic live pod restarts when credentials update in 1Password (`operator.autoRestart=true`).

### Required 1Password Items (Vault: `production`)

1. **`hermes`**:
   - `omniroute-api-key`: API key to authenticate Hermes against OmniRoute.
   - `hermes-api-key`: Hermes internal API gateway auth key.
2. **`hermes-dashboard`**:
   - `username`: Basic auth username (e.g. `admin`).
   - `password`: Basic auth password.
   - `signing-secret`: 32+ byte session signing secret.
3. **`omniroute`**:
   - `jwt-secret`: 32+ byte JWT token secret.
   - `api-key-secret`: 32-byte hex secret for hashing API keys.
   - `inference-api-key`: Key presented by clients for inference routing.
4. **`argocd-github-app`**:
   - `type`: `git`
   - `url`: `https://github.com`
   - `githubAppID`: GitHub App ID.
   - `githubAppInstallationID`: GitHub App Installation ID.
   - `githubAppPrivateKey`: GitHub App PEM Private Key.

---

## Deployment Workflow

```bash
# 1. Start Kind Cluster
./scripts/cluster.sh create

# 2. Ingress & Secrets
./scripts/cluster.sh install-traefik
export OP_SERVICE_ACCOUNT_TOKEN="ops_eyJhbG..."
./scripts/cluster.sh install-1password

# 3. ArgoCD & GitOps Workloads
./scripts/cluster.sh install-argocd
./scripts/cluster.sh install-apps

# (Or deploy workloads directly without ArgoCD)
# ./scripts/cluster.sh install-omniroute
# ./scripts/cluster.sh install-hermes
```

---

## Verification

```bash
kubectl -n hermes exec deployment/hermes-agent -c hermes -- \
  curl -fsS http://omniroute.omniroute.svc.cluster.local:20128/healthz
```
