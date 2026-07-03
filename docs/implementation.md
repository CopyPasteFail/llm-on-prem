# v0.1.0 Implementation Overview

## Repository content

- `charts/llm-serving/`: Helm chart for LiteLLM, one active vLLM Deployment, Services, Ingress, NetworkPolicy, ServiceAccount, optional ServiceMonitor, and model-cache PVC.
- `charts/llm-serving/values/gx10.yaml`: tracked GX10 desired state, including the active model release and immutable image digests.
- `argocd/llm-serving.application.example.yaml`: Argo CD Application bootstrap template.
- `.gitlab-ci.yml`: validation-only Helm lint and manifest rendering.
- `scripts/validate-helm.sh`: local chart validation.
- `scripts/smoke-api.sh`: manual read-only API smoke test.
- `examples/llm-serving-secrets.example.yaml`: Secret key shape with placeholders only.

## Not created here

- Kubernetes or K3s installation
- GX10 GPU driver, container-runtime, and Kubernetes device-plugin integration
- Argo CD installation or repository credentials
- Existing GitLab, runners, or registry credentials
- Real Secret values
- Container images
- A live Argo CD Application
- A GitLab deployment job

## First changes before bootstrap

1. Validate that the GX10 exposes `nvidia.com/gpu: 1` to Kubernetes.
2. Replace placeholder image digests in `values/gx10.yaml` with tested Arm64 images.
3. Set the exact model revision and benchmarked vLLM settings.
4. Set ingress and storage values.
5. Run `sh scripts/validate-helm.sh`.
6. Bootstrap the Argo CD Application from its template.

## Expected release

```text
Ingress -> LiteLLM -> private vLLM Service -> one vLLM Deployment -> GX10 GPU
```

The vLLM Deployment requests `nvidia.com/gpu: 1`, has one replica, and uses `Recreate`. A model replacement is a Git change to the tracked GX10 values followed by Argo CD reconciliation.
