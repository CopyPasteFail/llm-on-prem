# Credential Handling

Keep desired state in Git and keep credential values outside Git.

The application reads externally managed Kubernetes Secrets. The chart only contains Secret names and key references.

## Application access

Create the gateway and private vLLM credential Secret before the first synchronization. The required key names are documented in `examples/llm-serving-secrets.example.yaml`.

## Private image registry

For a private GitLab registry, create an image-pull Secret outside Git and reference its name in `imagePullSecrets` in the GX10 values file.

## Gated model access

For an approved private or gated model, create an external model-download credential and reference its Secret name in `vllm.huggingFaceToken`. Leave that field empty for public models.

## Later database features

Database-backed LiteLLM features are deferred from v0.1.0. Add database credentials only in a separate reviewed phase.

## Rotation

Rotate external credentials through the approved platform process, then reconcile affected workloads. Do not store credential values in this repository.
