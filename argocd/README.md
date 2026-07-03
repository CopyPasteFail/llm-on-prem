# Argo CD Bootstrap

These manifests are examples only. They are not active until copied, configured, and applied through the approved platform bootstrap process.

## Required order

1. Create `llm-serving.project.yaml` from `llm-serving.project.example.yaml`.
2. Replace the placeholder GitLab URL with the real internal repository URL.
3. Apply the AppProject.
4. Create `llm-serving.application.yaml` from `llm-serving.application.example.yaml`.
5. Use the same repository URL and set the approved branch or tag.
6. Apply the Application.

The Application is restricted to the `llm-serving` AppProject. It may read only the configured repository and deploy only to `llm-serving` on the in-cluster destination.

The project blocks the application from managing Kubernetes Secrets and RBAC Role or RoleBinding resources. Those are platform-managed boundaries and must not be introduced by the application chart.

## Sync behavior

- Automated sync is enabled after bootstrap.
- Self-heal is enabled.
- Prune is disabled in v0.1.0 to avoid accidental deletion while the platform is first being established.
- A Git revert restores a prior desired state for normal model rollback.
