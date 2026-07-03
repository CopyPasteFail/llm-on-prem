# llm-serving Helm Chart

## Purpose

Deploy the v0.1.0 internal LLM service into one `llm-serving` namespace:

```text
internal ingress -> LiteLLM -> private vLLM Service -> one vLLM pod -> GX10 GPU
```

## Invariants

- One active vLLM replica.
- Full GPU request: `nvidia.com/gpu: 1`.
- `Recreate` deployment strategy.
- Stable LiteLLM alias: `company-code`.
- vLLM is private to the cluster and receives traffic only from LiteLLM through the rendered NetworkPolicy.
- Images are referenced by immutable digest.
- Model ID and revision are defined in tracked values.

## Values files

- `values.yaml`: safe chart defaults.
- `values/gx10.yaml`: tracked desired state for the actual GX10 release. Replace its example image digests and model revision before Argo CD bootstrap.
- `values/gx10.example.yaml`: a copyable reference for experimenting with values structure.

## Local validation

```bash
sh scripts/validate-helm.sh
```

To validate a different values file:

```bash
VALUES_FILE=charts/llm-serving/values/gx10.example.yaml sh scripts/validate-helm.sh
```

This runs only Helm lint, template rendering, and offline manifest guard checks. It does not contact Kubernetes.

## Storage

The chart creates the `llm-model-cache` PVC by default. Set `vllm.modelCache.create: false` and set `vllm.modelCache.existingClaim` only when the storage is managed outside this chart.

## Secrets

The chart expects a pre-existing Kubernetes Secret. It does not create or populate secrets. See `examples/llm-serving-secrets.example.yaml` and `docs/secrets.md`.
