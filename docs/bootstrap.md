# v0.1.0 Bootstrap Runbook

Use this runbook only after the GX10 GPU validation gate passes. It prepares the first intentional application deployment; it does not assume that every Git change should deploy immediately.

## Prerequisites

Before bootstrapping the application, provide these platform prerequisites outside this chart:

- A healthy K3s cluster with one GX10 node.
- A validated GX10 driver, container runtime, and Kubernetes GPU integration that exposes `nvidia.com/gpu: 1`.
- An ingress controller and internal DNS/TLS arrangement.
- Argo CD installed in its own namespace.
- A storage class that can dynamically provision the chart-managed model-cache PVC. Alternatively, set `vllm.modelCache.create: false` and provide an existing claim.
- Existing internal GitLab repository access configured in Argo CD.
- A real secret named `llm-serving-secrets` in `llm-serving`.

Do not bootstrap until a tested Arm64 LiteLLM image, tested Arm64 vLLM image, and one model release are available.

## Prepare desired state

1. Set the actual model release in `charts/llm-serving/values/gx10.yaml`.
2. Replace example image repositories and digests with tested immutable image digests.
3. Set the exact model revision, context limit, memory utilization, concurrency, cache size, and reviewed vLLM flags.
4. Set the internal ingress hostname and, where needed, ingress class and TLS settings.
5. Keep `trustRemoteCode: false`.
6. Commit the reviewed desired state to the protected branch that Argo CD will track.

Model release values are intentionally kept in Git. Credentials remain outside Git.

## Local and GitLab validation

Run before opening a merge request:

```bash
sh scripts/validate-helm.sh
```

This runs GitOps-layout checks, Helm lint, manifest rendering, and rendered-manifest guards. It does not contact a cluster.

The GitLab pipeline runs the same validation-only checks for merge requests and the default branch. It has no image-build or Kubernetes deployment job.

## Create the application secret

Use the approved secret-management method to create `llm-serving-secrets` in `llm-serving`. Required keys are documented in `examples/llm-serving-secrets.example.yaml`.

Never commit populated Secret files, registry credentials, certificates, or Hugging Face tokens.

## Bootstrap Argo CD once

1. Copy `argocd/llm-serving.project.example.yaml` to `argocd/llm-serving.project.yaml`.
2. Set its source repository URL to the real internal GitLab repository URL.
3. Apply the AppProject through the approved platform-admin process.
4. Copy `argocd/llm-serving.application.example.yaml` to `argocd/llm-serving.application.yaml`.
5. Set the same real repository URL and the protected deployment branch or immutable tag.
6. Apply the Application through the approved platform-admin process.

After this bootstrap, normal application changes are reviewed Git changes. Argo CD is the only application deployer.

## First deployment checks

After the intentional first sync:

```bash
kubectl -n llm-serving get pods,svc,ingress,pvc
kubectl -n llm-serving rollout status deployment/llm-serving-vllm --timeout=20m
kubectl -n llm-serving rollout status deployment/llm-serving-litellm --timeout=5m
sh scripts/smoke-api.sh
```

The smoke script requires an endpoint and LiteLLM key supplied through the local environment. It does not change cluster state.

## Model replacement and rollback

A model replacement is a reviewable change to `charts/llm-serving/values/gx10.yaml`.

The vLLM Deployment uses `Recreate`, so the prior model pod stops before the replacement model loads. Verify the stable API after synchronization. If the candidate is unsuitable, revert the values commit. Argo CD restores the previous known-good desired state.
