# ADR-0002: K3s and the GX10 GPU Enablement Path

**Status:** Partially accepted — K3s accepted; GPU Operator requires hardware validation

## Context

The v0.1.0 platform runs one active vLLM model on one ASUS Ascent GX10. It needs Kubernetes resources, Helm, Argo CD reconciliation, and an NVIDIA GPU resource exposed to workloads without adding unnecessary single-node operational complexity.

NVIDIA's current GPU Operator support matrix explicitly lists DGX Spark as a supported Blackwell and ARM-based platform, and lists K3s as a validated Kubernetes platform. The same document also states that GPU Operator supports platforms using discrete GPUs and excludes integrated-GPU embedded products. ASUS GX10 is an OEM GB10 system and is not named separately. The public documentation is therefore not enough to claim confirmed GX10 support.

## Decision

Use a single-node K3s cluster on the GX10.

Treat NVIDIA GPU Operator as the first GPU enablement candidate, not as a pre-confirmed GX10 guarantee. Do not deploy `llm-serving` until the actual GX10 proves that the selected driver, container runtime, K3s version, and GPU Operator version expose a stable `nvidia.com/gpu: 1` resource and can run an Arm64 GPU test workload.

The application chart depends only on the standard Kubernetes `nvidia.com/gpu` resource. It does not use GPU Operator custom resources, so the chart can remain unchanged if another supported device-plugin path is required.

## Rationale

- K3s is a complete Kubernetes distribution suited to one-node Arm64 deployments.
- Helm and Argo CD use standard Kubernetes APIs and do not need a larger distribution for v0.1.0.
- GPU Operator is the most suitable initial candidate because NVIDIA documents DGX Spark and K3s in its support matrix.
- The GX10 is distinct hardware, and the support-matrix wording about integrated GPUs creates a real verification requirement rather than a safe assumption.

## Consequences

- GPU Operator is not part of the `llm-serving` Helm chart.
- The first infrastructure acceptance test must prove that a K3s node exposes `nvidia.com/gpu: 1` and that an Arm64 GPU workload can use it.
- If this test fails, stop before application deployment and choose a confirmed GX10-compatible GPU device-plugin path.
- K3s, the chosen GPU integration, operating system, driver, container runtime, and selected vLLM image must be version-tested as one compatibility set.

## Revisit conditions

Revisit this decision after the GX10 validation run, if the organization standardizes on another Kubernetes distribution, or if the platform expands beyond a single node.
