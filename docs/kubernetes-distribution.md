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
- NVIDIA lists K3s among the validated Kubernetes platforms for GPU Operator.

## GX10 GPU enablement

The application chart requires a Kubernetes node that exposes `nvidia.com/gpu: 1`.

NVIDIA's current GPU Operator platform-support matrix explicitly lists DGX Spark under supported Blackwell systems and supported ARM-based platforms. It also lists K3s as a validated Kubernetes distribution. The ASUS GX10 uses the same GB10 platform but is a different vendor product, so the exact GX10 operating-system, driver, container-runtime, and GPU Operator combination should be validated before the first real deployment.

Recommended validation sequence:

1. Confirm the NVIDIA driver and `nvidia-smi` work on the GX10 host.
2. Install K3s and NVIDIA GPU Operator using the supported configuration for the installed Ubuntu release.
3. Confirm the node advertises `nvidia.com/gpu: 1`.
4. Run a test pod that requests the GPU.
5. Run the selected Arm64 vLLM image with a small model before using the main model release.

The Helm chart does not depend on GPU Operator-specific APIs. It only requires the standard `nvidia.com/gpu` resource, so the device-plugin implementation can be changed later if needed.

## Recommended profile

- One K3s server on the GX10 using the embedded datastore.
- K3s containerd runtime.
- NVIDIA GPU Operator for driver, container toolkit, GPU device plugin, and GPU observability components.
- Keep K3s network policy enabled unless it is deliberately replaced.
- Use built-in Traefik only when it is the selected internal ingress controller. Otherwise disable it and install the organization-standard controller.
- Keep Kubernetes, Argo CD, LiteLLM, and vLLM private to the corporate network or VPN.

## Alternatives

Use kubeadm when the organization already operates upstream Kubernetes or expects to add nodes soon.

Use RKE2 when an existing organization standard requires it.

MicroK8s can work, but it has no clear v0.1.0 advantage over K3s for this one-node design.

## Scope

The application chart does not install K3s, GPU Operator, Argo CD, ingress, DNS, TLS, or storage provisioning. Those remain cluster prerequisites.
