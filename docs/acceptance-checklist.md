# v0.1.0 Acceptance Checklist

## Repository acceptance

- [ ] `charts/llm-serving/values/gx10.yaml` contains reviewed, real image digests and an exact model revision.
- [ ] `trustRemoteCode` remains `false`, unless a separate security review explicitly approves a specific model exception.
- [ ] Helm chart validation and rendered-manifest checks pass.
- [ ] Argo CD Application and Project templates contain the real internal GitLab repository URL and intended branch.
- [ ] The secret template has not been populated or committed.
- [ ] Model release review confirms the license, source, quantization, and selected vLLM settings.

## Cluster acceptance

- [ ] K3s is healthy.
- [ ] NVIDIA GPU Operator is healthy on the GX10.
- [ ] The GX10 node advertises `nvidia.com/gpu: 1`.
- [ ] A minimal Arm64 GPU workload successfully requests the GPU.
- [ ] The selected Arm64 vLLM image starts with a small model.
- [ ] Internal DNS, ingress, and TLS follow the agreed network design.
- [ ] The real `llm-serving-secrets` Secret exists outside Git.

## Application acceptance

- [ ] Argo CD reports the `llm-serving` Application as synchronized and healthy.
- [ ] The model-cache PVC is bound.
- [ ] LiteLLM is reachable only through the intended internal ingress.
- [ ] The vLLM Service has no external ingress route.
- [ ] Requests to `company-code` return a valid response.
- [ ] The API smoke test passes with a real LiteLLM key.
- [ ] A Git revert has been reviewed as the normal model rollback mechanism.
