## Platform change

- [ ] Scope is chart, Argo CD, CI validation, or operator documentation.
- [ ] Change does not add a direct GitLab-to-Kubernetes deployment action.
- [ ] Change does not add credentials or populated Secret manifests to Git.
- [ ] Change is compatible with one active vLLM model and `Recreate` strategy.
- [ ] Network exposure and NetworkPolicy impact were reviewed.
- [ ] Storage/PVC impact was reviewed.
- [ ] `sh scripts/validate-helm.sh` passed.
- [ ] Rollback is a Git revert or is documented separately.
