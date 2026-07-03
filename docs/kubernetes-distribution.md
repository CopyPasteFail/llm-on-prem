# Kubernetes Distribution for the GX10

## Decision

Use K3s as the preferred Kubernetes distribution for v0.1.0.

The v0.1.0 platform has one GX10, one namespace, one active GPU-serving model, and no high-availability requirement. The Helm chart and Argo CD Application use standard Kubernetes APIs, so they can move to another conformant distribution later.

## Why K3s

- K3s supports Arm64.
- A single K3s server is a complete Kubernetes cluster.
- It has a smaller operational footprint than a larger multi-node installation.
- It provides the Kubernetes APIs needed by Helm, Argo CD, LiteLLM, and vLLM.
- K3s includes an ingress option and a network-policy controller, both useful for this small internal service.

## GX10 GPU enablement gate

The application chart requires a Kubernetes node that exposes `nvidia.com/gpu: 1`.

Do not assume that NVIDIA GPU Operator is the correct GX10 solution. NVIDIA's public GPU Operator support documentation states that the operator supports discrete GPUs and does not support embedded or integrated GPUs. The GX10 path must therefore be validated on the actual machine before it becomes a cluster prerequisite.

Validate this sequence before bootstrapping the application:

1. Confirm the NVIDIA driver and `nvidia-smi` work on the GX10 host.
2. Confirm the selected container runtime can access the GPU from an Arm64 test container.
3. Install and validate a GX10-compatible Kubernetes GPU device-plugin path.
4. Run a test pod that requests `nvidia.com/gpu: 1`.
5. Run the selected vLLM image and a small model before using the main model release.

No Kubernetes distribution changes this hardware-support validation. K3s remains appropriate for the control plane once the GPU resource is available.

## Recommended profile

- One K3s server on the GX10 using the embedded datastore.
- K3s containerd runtime.
- Keep K3s network policy enabled unless it is deliberately replaced.
- Use built-in Traefik only when it is the selected internal ingress controller. Otherwise disable it and install the organization-standard controller.
- Keep Kubernetes, Argo CD, LiteLLM, and vLLM private to the corporate network or VPN.

## Alternatives

Use kubeadm when the organization already operates upstream Kubernetes or expects to add nodes soon.

Use RKE2 when an existing organization standard requires it.

MicroK8s can work, but it has no clear v0.1.0 advantage over K3s for this one-node design.

## Scope

The application chart does not install K3s, the GX10 GPU device-plugin path, Argo CD, ingress, DNS, TLS, or storage provisioning. Those remain cluster prerequisites.
