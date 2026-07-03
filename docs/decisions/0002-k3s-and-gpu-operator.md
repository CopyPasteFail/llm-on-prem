# ADR-0002: K3s and NVIDIA GPU Operator for v0.1.0

**Status:** Accepted

## Context

The v0.1.0 platform runs one active vLLM model on one ASUS Ascent GX10. It needs Kubernetes resources, Helm, Argo CD reconciliation, an NVIDIA GPU resource exposed to workloads, and a path that does not add unnecessary single-node operational complexity.

## Decision

Use a single-node K3s cluster on the GX10 and use NVIDIA GPU Operator as the planned GPU enablement path.

The application chart depends only on Kubernetes exposing `nvidia.com/gpu: 1`. It does not use GPU Operator custom resources, so the chart remains portable if a different supported device-plugin implementation becomes necessary.

## Rationale

- K3s is a complete Kubernetes distribution suited to one-node Arm64 deployments.
- Helm and Argo CD work with standard Kubernetes APIs and do not need a larger distribution for v0.1.0.
- NVIDIA lists DGX Spark and K3s in its current GPU Operator support material. The GX10 uses the GB10 platform, but it is a distinct vendor product, so the exact GX10 software combination must be validated before the first real application deployment.
- GPU Operator supplies the standard components normally required for Kubernetes GPU scheduling and observability.

## Consequences

- GPU Operator installation is a cluster prerequisite, not part of the `llm-serving` Helm chart.
- The first infrastructure acceptance test must prove that a K3s node exposes `nvidia.com/gpu: 1` and that an Arm64 GPU workload can use it.
- K3s, GPU Operator, the installed operating system, driver, container runtime, and selected vLLM image must be version-tested as one compatibility set.

## Revisit conditions

Revisit this decision if the GX10 cannot expose a stable Kubernetes GPU resource through the planned combination, if the organization standardizes on another Kubernetes distribution, or if the platform expands beyond a single node.
