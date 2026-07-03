# Model Release Workflow

## Purpose

The tracked file `charts/llm-serving/values/gx10.yaml` is the model-release record for v0.1.0.

It defines the one model that the GX10 serves through the stable LiteLLM alias `company-code`.

## Values that change for a new model

Update only the model release fields that were tested together:

```yaml
vllm:
  image:
    repository: registry.example.internal/llm/vllm
    digest: sha256:exact-tested-image-digest
  model:
    id: publisher/model-name
    revision: exact-model-revision
    dtype: auto
    quantization: ""
    trustRemoteCode: false
    maxModelLen: 8192
    gpuMemoryUtilization: 0.80
    maxNumSeqs: 8
    maxNumBatchedTokens: 4096
    extraArgs: []
```

The model repository revision and image digest must be immutable. Do not use floating model branches or mutable image tags for an approved release.

## Values that normally remain stable

Keep these stable unless the platform design itself changes:

- LiteLLM alias: `company-code`
- LiteLLM and vLLM Service names
- Ingress hostname
- Namespace: `llm-serving`
- GPU limit: `nvidia.com/gpu: 1`
- vLLM replica count: `1`
- Deployment strategy: `Recreate`
- NetworkPolicy and secret references

## Review checklist

Before merging a model replacement:

1. Confirm the vLLM image and model revision support the GX10 Arm64 environment.
2. Confirm the selected model has a documented license and approved source.
3. Benchmark the model with the exact context, concurrency, and memory settings in the values file.
4. Verify the image digest, model revision, quantization, and vLLM flags are all pinned.
5. Run `./scripts/validate-helm.sh`.
6. Review the rendered manifest in GitLab CI.

## Promotion and rollback

After merge, Argo CD applies the new desired state. Kubernetes stops the active vLLM pod, then starts the replacement because the deployment uses `Recreate`.

The stable client endpoint and `company-code` alias do not change.

To roll back, revert the model-release commit. Argo CD reconciles the earlier model values and recreates the previous known-good vLLM pod.
