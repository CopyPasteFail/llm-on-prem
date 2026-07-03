# v0.1.0 Acceptance Checklist

## Repository acceptance

- [ ] `charts/llm-serving/values/gx10.yaml` contains reviewed, real image digests and an exact model revision.
- [ ] `trustRemoteCode` is `false`; chart validation rejects `true`.
- [ ] Local Helm, GitOps layout, and rendered-manifest checks pass.
- [ ] The internal GitLab validation pipeline passes.
- [ ] Argo CD templates contain the real internal GitLab URL and protected deployment branch.
- [ ] No populated Secret or registry credential is committed.
- [ ] The model license, source, quantization, and vLLM settings were reviewed.

## Cluster acceptance

- [ ] K3s is healthy.
- [ ] The chosen GX10 GPU integration is validated; GPU Operator is only the first candidate.
- [ ] The GX10 node advertises `nvidia.com/gpu: 1`.
- [ ] An Arm64 workload can request and use one GPU.
- [ ] The selected Arm64 vLLM image starts a small model.
- [ ] Internal DNS, ingress, and TLS follow the agreed network design.
- [ ] The real `llm-serving-secrets` Secret exists outside Git.

## Application acceptance

- [ ] Argo CD reports the application as synchronized and healthy.
- [ ] The model-cache PVC is bound.
- [ ] LiteLLM readiness and liveness probes are healthy.
- [ ] External LiteLLM access uses the intended internal ingress path.
- [ ] vLLM has no external ingress route and accepts traffic only from LiteLLM pods.
- [ ] `company-code` returns a valid response.
- [ ] The API smoke test passes with a real LiteLLM key.
- [ ] The shared gateway-key boundary is accepted for the limited pilot scope.
- [ ] A Git revert has been reviewed as the normal model rollback method.
