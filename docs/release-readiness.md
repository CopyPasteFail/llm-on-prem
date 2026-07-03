# Release Readiness Gate

Run these checks after setting the real GX10 values and before Argo CD bootstrap.

```bash
sh scripts/validate-helm.sh
sh scripts/check-release-ready.sh
```

`validate-helm.sh` checks repository layout, Helm values, rendered resources, and v0.1.0 invariants.

`check-release-ready.sh` rejects the built-in example image registry, image digests, model revision, and ingress hostname.

Proceed only when both checks succeed and the GX10 Kubernetes node already exposes `nvidia.com/gpu: 1`.
