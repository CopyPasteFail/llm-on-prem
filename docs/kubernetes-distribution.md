# Kubernetes Distribution for the GX10

## Decision

Use K3s as the preferred Kubernetes distribution for v0.1.0.

The v0.1.0 platform has one GX10, one namespace, one active GPU-serving model, and no high-availability requirement. The Helm chart and Argo CD Application use standard Kubernetes APIs, so they can move to another conformant distribution later.

## Why K3s

- K3s supports Arm64.
- A single K3s server is a complete Kubernetes cluster.
- It has a smaller operational footprint than a larger multi-node installation.
- It provides the Kubernetes APIs needed by Helm, Argo CD, NVIDIA GPU Operator, LiteLLM, and vLLM.
- NVIDIA lists K3s in the GPU Operator platform support matrix. Validate the exact K3s, Ubuntu, driver, GPU Operator, and Arm64 image combination on the GX10 before production use.

## Recommended profile

- One K3s server on the GX10 using the embedded datastore.
- K3s containerd runtime.
- NVIDIA GPU Operator installed after K3s is healthy.
- Keep K3s network policy enabled unless it is deliberately replaced.
- Use built-in Traefik only when it is the selected internal ingress controller. Otherwise disable it and install the organization-standard controller.
- Keep Kubernetes, Argo CD, LiteLLM, and vLLM private to the corporate network or VPN.

## Alternatives

Use kubeadm when the organization already operates upstream Kubernetes or expects to add nodes soon.

Use RKE2 when an existing organization standard requires it.

MicroK8s can work, but it has no clear v0.1.0 advantage over K3s for this one-node design.

## Scope

The application chart does not install K3s, GPU Operator, Argo CD, ingress, DNS, TLS, or storage provisioning. Those remain cluster prerequisites.
