# GitOps v0.1.0

## Decision

Helm defines the application. Argo CD is the only application deployer. The existing on-prem GitLab provides source control, validation CI, and image registry.

GitLab CI validates the tracked Helm chart and GX10 values. It does not apply workloads to Kubernetes.

## Repository state

```text
charts/llm-serving/
  Chart.yaml
  values.yaml
  values.schema.json
  values/gx10.yaml
  templates/

argocd/llm-serving.application.example.yaml
scripts/validate-helm.sh
scripts/smoke-api.sh
.gitlab-ci.yml
```

`charts/llm-serving/values/gx10.yaml` is tracked desired state. It contains the active model release, immutable image digests, capacity settings, cache settings, and ingress settings. It contains no credentials.

## Chart version

```yaml
version: 0.1.0
appVersion: "0.1.0"
```

`version` changes when chart behavior changes. A model-only replacement changes the GX10 values file and keeps the chart version unchanged.

## Managed resources

The chart manages LiteLLM, one active vLLM Deployment, their Services, the model-cache PVC, Ingress, NetworkPolicy, ServiceAccount, ConfigMaps, and optional ServiceMonitor.

The chart creates the model-cache PVC by default. Set `vllm.modelCache.create: false` only when using an existing claim.

## Prerequisites

Kubernetes, GPU Operator, storage provisioner, ingress, internal DNS/TLS, Argo CD, Argo repository access, GitLab, runners, and real Secret values remain outside this chart.

## Argo CD bootstrap

The Application manifest is an example. Set the internal GitLab repository URL and tracked branch, then apply it once through the approved bootstrap process. After that, Argo CD reconciles reviewed Git changes.

## Model replacement and rollback

```text
Change values/gx10.yaml
→ GitLab CI validates
→ merge
→ Argo CD reconciles
→ Kubernetes recreates the one vLLM pod
→ verify company-code
→ retain or revert the Git commit
```

The vLLM Deployment uses `Recreate`. A Git revert is the normal rollback mechanism.
