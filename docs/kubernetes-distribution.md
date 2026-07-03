# Kubernetes Distribution for the GX10

## Decision

Use K3s as the preferred Kubernetes distribution for v0.1.0.

The platform has one GX10, one namespace, one active GPU-serving model, and no high-availability requirement. The Helm chart and Argo CD Application use standard Kubernetes APIs, so they can move to another conformant distribution later.

## Why K3s

- K3s supports Arm64.
- A single K3s server is a complete Kubernetes cluster.
- It has a smaller operational footprint than a larger multi-node installation.
- It provides the Kubernetes APIs needed by Helm, Argo CD, LiteLLM, and vLLM.
- K3s includes an ingress option and a network-policy controller, both useful for this small internal service.
- NVIDIA lists K3s among the validated Kubernetes platforms for GPU Operator.

## GX10 GPU enablement: required decision gate

The application chart requires a Kubernetes node that exposes `nvidia.com/gpu: 1`.

NVIDIA's current GPU Operator matrix explicitly lists DGX Spark as a Blackwell ARM platform and lists K3s as validated. It also separately states that GPU Operator only supports discrete-GPU platforms and excludes integrated-GPU embedded products. ASUS GX10 is not named separately. Therefore, GPU Operator is the first validation candidate, not a confirmed GX10 guarantee.

Do not deploy the application until this sequence succeeds:

1. Confirm the NVIDIA driver and `nvidia-smi` work on the GX10 host.
2. Install K3s.
3. Install the selected GPU integration candidate: NVIDIA GPU Operator first.
4. Confirm the node advertises `nvidia.com/gpu: 1`.
5. Run an Arm64 GPU test pod that requests the resource.
6. Run the selected Arm64 vLLM image with a small model.

If any GPU Operator step fails, stop before applying the application chart. Record the versions and error, then select a confirmed GX10-compatible GPU device-plugin path. The `llm-serving` chart remains usable because it depends only on `nvidia.com/gpu: 1`, not on GPU Operator custom resources.

## Recommended profile

- One K3s server on the GX10 using the embedded datastore.
- K3s containerd runtime.
- NVIDIA GPU Operator as the first GPU integration candidate, pending the GX10 validation gate.
- Keep K3s network policy enabled unless it is deliberately replaced.
- Use built-in Traefik only when it is the selected internal ingress controller. Otherwise disable it and install the organization-standard controller.
- Keep Kubernetes, Argo CD, LiteLLM, and vLLM private to the corporate network or VPN.

## Alternatives

Use kubeadm when the organization already operates upstream Kubernetes or expects to add nodes soon.

Use RKE2 when an existing organization standard requires it.

MicroK8s can work, but it has no clear v0.1.0 advantage over K3s for this one-node design.

## Scope

The application chart does not install K3s, GPU Operator, Argo CD, ingress, DNS, TLS, or storage provisioning. Those remain cluster prerequisites.
