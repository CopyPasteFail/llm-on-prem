# v0.1.0 Bootstrap Runbook

This runbook prepares the repository for its first intentional deployment. It does not assume that any Git change should deploy immediately.

## Prerequisites

Before bootstrapping the application, provide these cluster prerequisites outside this chart:

- A Kubernetes cluster with one GX10 node.
- NVIDIA GPU Operator installed and the node advertising `nvidia.com/gpu: 1`.
- An ingress controller and internal DNS/TLS arrangement.
- Argo CD installed in its own namespace.
- A storage class and a pre-created `llm-model-cache` PVC in `llm-serving`, sized for model weights and cache.
- Existing GitLab repository access configured in Argo CD.
- A real secret named `llm-serving-secrets` in `llm-serving`.

Do not bootstrap until a tested Arm64 LiteLLM image, a tested Arm64 vLLM image, and one model release are available.

## Prepare desired state

1. Set the actual model release in `charts/llm-serving/values/gx10.yaml`.
2. Replace the example image repositories and digests with tested immutable image digests.
3. Set the exact model repository revision, context limit, memory utilization, concurrency, and any reviewed vLLM flags.
4. Set the internal ingress hostname and, where needed, ingress class and TLS settings.
5. Commit the reviewed desired state to the branch Argo CD will track.

Model release values are intentionally kept in Git. Credentials remain outside Git.

## Local validation

Run before opening a merge request:

```bash
./scripts/validate-helm.sh
```

This only runs Helm lint and renders manifests to `rendered/`. It does not contact a cluster.

## GitLab CI validation

When the repository is available in the existing GitLab, `.gitlab-ci.yml` runs the same lint and render checks for merge requests and the default branch. It has no build or deployment job.

## Create the application secret

Use the approved secret-management method to create `llm-serving-secrets` in `llm-serving`. The required keys are documented in `examples/llm-serving-secrets.example.yaml`.

Never commit populated secret files.

## Bootstrap Argo CD once

1. Copy `argocd/llm-serving.application.example.yaml` to `argocd/llm-serving.application.yaml`.
2. Set `spec.source.repoURL` to the existing on-prem GitLab repository URL.
3. Set `targetRevision` to the protected branch that contains approved desired state.
4. Review the manifest.
5. Apply it once from an administrator workstation or through the approved platform bootstrap process.

After the Application exists, normal application changes are Git changes only. Argo CD reconciles the Helm release automatically.

## First deployment checks

After the intentional first sync:

```bash
kubectl -n llm-serving get pods,svc,ingress
kubectl -n llm-serving get deployment llm-serving-llm-serving-vllm
./scripts/smoke-api.sh
```

The smoke script requires an endpoint and LiteLLM API key supplied through the local environment. It does not change cluster state.

## Model replacement and rollback

A model replacement is a reviewable change to `charts/llm-serving/values/gx10.yaml`.

The vLLM Deployment uses `Recreate`, so the prior model pod stops before the replacement model loads. Verify the stable API after synchronization. If the candidate is unsuitable, revert the values commit. Argo CD restores the previous known-good desired state.
