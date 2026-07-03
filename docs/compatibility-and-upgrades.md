# Compatibility and Upgrade Policy

## Principle

Treat the GX10 runtime as one tested compatibility set, not as independently upgradeable components.

```text
Ubuntu release
+ K3s version
+ selected GPU integration version
+ NVIDIA driver and container runtime
+ Arm64 LiteLLM image digest
+ Arm64 vLLM image digest
+ model revision and quantization
```

NVIDIA GPU Operator is the first GPU integration candidate. Record it as part of the validated set only after the GX10 acceptance gate succeeds.

A change to any component can affect GPU availability, model loading, inference behavior, observability, or rollback.

## What is pinned in Git

The Helm release pins:

- chart version
- LiteLLM image digest
- vLLM image digest
- model identifier and exact revision
- quantization and vLLM runtime settings
- resource limits and model-cache configuration

Do not use mutable image tags or floating model branches in a reviewed model release.

## What is recorded outside this repository

Record the installed operating system, K3s, selected GPU integration, NVIDIA driver, container runtime, and validation result in the deployment change record or internal operations system after the first installation.

## Upgrade order

1. Review upstream compatibility notes for the proposed component change.
2. Test the change on the GX10 using a small model and the selected Arm64 images.
3. Confirm `nvidia.com/gpu: 1` remains available to Kubernetes.
4. Confirm the Helm release renders unchanged except for the intended update.
5. Commit the changed image or chart values.
6. Let Argo CD reconcile the approved revision.
7. Run the API smoke test and record the result.

## Rollback

- For application or model changes: revert the Git commit and let Argo CD reconcile.
- For cluster-level upgrades: use the rollback procedure for the installed K3s or selected GPU integration version, then verify the Kubernetes GPU resource before reconciling the application again.
