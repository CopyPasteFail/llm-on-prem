# Contribution Rules

## Core v0.1.0 invariants

- Keep one active vLLM replica.
- Keep `nvidia.com/gpu: 1`.
- Keep the vLLM deployment strategy `Recreate`.
- Keep `trustRemoteCode: false`.
- Do not add a direct GitLab-to-Kubernetes deployment job.
- Do not commit populated Secrets, tokens, registry credentials, or private keys.

## Before opening a merge request

Run:

```bash
sh scripts/validate-helm.sh
```

Review the rendered manifest in `rendered/llm-serving.yaml`.

## Model release changes

Use `.gitlab/merge_request_templates/Model Release.md` when changing `charts/llm-serving/values/gx10.yaml`.

A model release must pin the image digest and model revision, preserve the stable `company-code` alias, and identify the prior commit for rollback.

## Platform changes

Use `.gitlab/merge_request_templates/Platform Change.md` for chart, Argo CD, CI validation, storage, networking, or documentation changes.

Argo CD is the only application deployer. GitLab CI validates desired state only.
