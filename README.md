# Local Kind Cluster: Hermes & OmniRoute

Local Kubernetes cluster provisioning for Hermes Agent and OmniRoute model proxy with 1Password Service Account secret management.

---

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) or Podman
- [Kind](https://kind.sigs.k8s.io/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh/)
- 1Password Account with a Service Account Token (`ops_...`)

---

## Architecture Overview

```
1Password Cloud (production vault)
       │
       ▼ (1Password SDK via Service Account Token)
1Password Kubernetes Operator (`1password/connect` chart with `operator.authMethod=service-account`)
       │
       ▼ (Generates K8s Secrets from OnePasswordItem CRDs)
├── Namespace: omniroute  --> Secret: omniroute-auth
└── Namespace: hermes     --> Secrets: hermes-integrations, hermes-dashboard-auth
```

---

## 1Password Vault Setup

In your 1Password `production` vault, create the following items:

| Item Title | Field Names | Description |
|---|---|---|
| **`hermes`** | `omniroute-api-key`<br>`hermes-api-key` | Auth keys for OmniRoute endpoint and Hermes API server |
| **`hermes-dashboard`** | `username`<br>`password`<br>`signing-secret` | Dashboard basic authentication credentials |
| **`omniroute`** | `jwt-secret`<br>`api-key-secret`<br>`inference-api-key` | OmniRoute internal auth and client keys |
| **`argocd-github-app`** | `type`<br>`url`<br>`githubAppID`<br>`githubAppInstallationID`<br>`githubAppPrivateKey` | ArgoCD GitHub App authentication credentials |

---

## Quickstart

### 1. Create Cluster

```bash
./scripts/cluster.sh create
```

### 2. Install Traefik Ingress Controller

```bash
./scripts/cluster.sh install-traefik
```

### 3. Deploy 1Password Operator & Sync Secrets

```bash
export OP_SERVICE_ACCOUNT_TOKEN="ops_eyJhbG..."
./scripts/cluster.sh install-1password
```

### 4. Deploy ArgoCD & GitOps Applications

```bash
# Install ArgoCD
./scripts/cluster.sh install-argocd

# Deploy Applications via ArgoCD ApplicationSet (GitOps auto-sync)
./scripts/cluster.sh install-apps
```

*Alternatively, deploy directly without GitOps:*
```bash
./scripts/cluster.sh install-omniroute
./scripts/cluster.sh install-hermes
```

---

## Alternative: Manual Secret Configuration (without 1Password)

If deploying without 1Password, export required values and run:

```bash
export OMNIROUTE_API_KEY="sk-..."
export OMNIROUTE_JWT_SECRET="$(openssl rand -base64 48)"
export OMNIROUTE_API_KEY_SECRET="$(openssl rand -hex 32)"
export HERMES_API_KEY="$(openssl rand -hex 32)"
export HERMES_DASHBOARD_PASSWORD="$(openssl rand -base64 24)"
export HERMES_DASHBOARD_SIGNING_SECRET="$(openssl rand -base64 48)"

./scripts/cluster.sh configure-integrations
```

---

## Verification

```bash
# Check 1Password Operator items
kubectl get onepassworditems -A

# Check synced Kubernetes Secrets
kubectl get secrets -n hermes
kubectl get secrets -n omniroute

# Check running workloads
kubectl get pods -n hermes
kubectl get pods -n omniroute
```

## Infrastructure layout

Terraform modules and Terragrunt environment configuration are organized under
`infra/`: reusable modules live in `infra/modules/`, and per-machine or
per-cluster Terragrunt configuration belongs under `infra/live/`. Cluster
configuration files live in `clusters/`. The Kind module and Terragrunt unit
are scaffolding locations; the current cluster lifecycle is still handled by
`scripts/cluster.sh` until the Terraform module is implemented.

Keep machine-specific host paths out of shared cluster configuration where
possible. Terraform state, Terragrunt caches, and local `*.tfvars` files are
ignored by Git.
