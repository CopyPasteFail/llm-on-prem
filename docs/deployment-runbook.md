# Deployment Runbook

## Prerequisites

- Reviewed content is pushed to the protected internal GitLab deployment branch.
- GitLab validation passes.
- K3s is healthy.
- The GX10 GPU integration has been validated and the node exposes `nvidia.com/gpu: 1`.
- A small model starts with the selected Arm64 vLLM image.
- `values/gx10.yaml` has real image digests, a pinned model revision, benchmarked settings, and an internal ingress hostname.
- The real `llm-serving-secrets` object exists outside Git.

## Pre-deployment validation

Run locally:

```bash
sh scripts/validate-helm.sh
```

The command validates repository state and renders the chart without contacting a cluster.

## Argo CD bootstrap

1. Configure the AppProject template with the real internal GitLab URL.
2. Configure the Application template with the same URL and protected branch.
3. Apply the project before the application.

Argo CD becomes the only application deployer.

## First synchronization

Confirm the application is synchronized and healthy, the model-cache PVC is bound, external access follows the intended internal ingress path, and vLLM has one ready pod with no external route.

## API check

Supply the internal API endpoint and LiteLLM key through the local environment, then run:

```bash
sh scripts/smoke-api.sh
```

## Model change

Change only the reviewed model release fields in `values/gx10.yaml`, validate, merge, and let Argo CD reconcile. Revert that Git commit to roll back.
