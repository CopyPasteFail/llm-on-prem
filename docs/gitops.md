# GitOps v0.1.0

## Decision

Version 0.1.0 uses Argo CD for continuous delivery and Helm for the application definition.

The existing on-prem GitLab remains the Git host, CI system, and container registry. GitLab CI validates changes and builds custom images when custom deployment code changes. Argo CD is the component that applies the desired state to Kubernetes.

## Why this split

```text
GitLab CI
  validates Git changes
  builds immutable images when application code changes
  does not apply workloads directly to Kubernetes

Argo CD
  reads the approved Git revision
  renders the Helm chart
  reconciles Kubernetes to the declared state
```

This keeps the desired state, model selection, and rollback history in Git. It also avoids giving GitLab CI a direct application-deployment role in the cluster.

## Repository layout

For v0.1.0, use one Git repository:

```text
charts/
  llm-serving/
    Chart.yaml
    values.yaml
    values.schema.json
    templates/
    values/
      gx10.yaml

argocd/
  llm-serving.application.yaml

docs/
.gitlab-ci.yml
```

`charts/llm-serving/values.yaml` contains safe chart defaults. `charts/llm-serving/values/gx10.yaml` is the sole desired-state file for this GX10 deployment.

## Helm chart versioning

```yaml
apiVersion: v2
name: llm-serving
version: 0.1.0
appVersion: "0.1.0"
```

- `version` is the chart release marker. It changes when templates, schema, dependencies, or deployment behavior change.
- `appVersion` is informational. For v0.1.0 it records the first application-bundle version.
- A model-only replacement changes `values/gx10.yaml`, not the chart version.
- Container images use immutable digests. Do not use a mutable `latest` tag for a release.

## Stable values

These values normally remain unchanged during a model replacement:

```yaml
namespace: llm-serving

service:
  name: vllm
  port: 8000

ingress:
  host: llm.internal.example

gpu:
  resourceName: nvidia.com/gpu
  count: 1

vllmDeployment:
  strategy: Recreate

modelCache:
  existingClaim: llm-model-cache

litellm:
  servedModelName: company-code
```

## Model release values

The model-release block is the normal change surface for a new model or rollback:

```yaml
model:
  id: Qwen/EXAMPLE
  revision: exact-model-revision
  tokenizer: null
  tokenizerRevision: null
  dtype: bfloat16
  quantization: null
  trustRemoteCode: false
  maxModelLen: 32768
  gpuMemoryUtilization: 0.80
  maxNumSeqs: 16
  maxNumBatchedTokens: 8192
  extraArgs: []

runtime:
  image: registry.internal.example/llm/vllm@sha256:exact-image-digest
```

Model-specific values must be benchmarked together. A model change can require changes to its context limit, quantization, vLLM image, memory utilization, concurrency, and additional runtime flags.

## Argo CD application

Argo CD tracks the GitLab repository, branch, chart path, and GX10 values file. Auto-sync is enabled after an approved merge to the tracked branch.

Recommended v0.1.0 behavior:

```text
automated sync: enabled
self-heal: enabled
prune: disabled initially
sync trigger: approved Git change
```

The first Argo CD Application is a bootstrap resource. Once Argo CD is installed and the application exists, normal application changes happen only through Git.

## GitLab CI responsibilities

For every merge request that affects the chart or values:

- Run `helm lint`.
- Render manifests with `helm template` using the GX10 values.
- Validate rendered Kubernetes manifests.
- Run chart schema and policy checks.

For a change to custom deployment code or a custom vLLM image:

- Build an Arm64-compatible image.
- Publish it to the existing GitLab Container Registry.
- Record its immutable digest in a Git change to `values/gx10.yaml`.
- Let Argo CD deploy the resulting Git revision.

GitLab CI does not perform an application deployment itself.

## Model replacement and rollback

```text
1. Change model values in a branch.
2. GitLab CI validates chart and manifests.
3. Merge the reviewed change.
4. Argo CD synchronizes the Helm release.
5. Kubernetes stops the old vLLM pod and starts the replacement.
6. Confirm the stable LiteLLM endpoint and company-code alias work.
7. Keep the commit or revert it.
```

Rollback is a Git revert of the model-release values. Argo CD then converges the cluster to the previous known-good configuration.

## v0.1.0 boundaries

The application chart manages LiteLLM, one active vLLM Deployment, its Service, ConfigMaps, Secret references, PVC references, Ingress, NetworkPolicy, and monitoring integration.

Cluster prerequisites remain separate from this chart:

- Kubernetes cluster and storage provisioner
- NVIDIA GPU Operator
- Ingress controller and internal TLS arrangement
- Argo CD installation
- Existing GitLab and its runners
