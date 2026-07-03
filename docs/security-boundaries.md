# v0.1.0 Security Boundaries

## Enforced by the chart

- vLLM has a private ClusterIP Service and no Ingress resource.
- The vLLM NetworkPolicy allows inbound traffic only from LiteLLM pods in `llm-serving`.
- LiteLLM-to-vLLM calls use a separate `VLLM_API_KEY`.
- Client calls to LiteLLM require `LITELLM_MASTER_KEY`.
- Pods run without privilege escalation and with dropped Linux capabilities.
- The application project blocks Argo CD from applying Secret, Role, and RoleBinding resources.
- The chart does not contain populated credentials.

## Not enforced by the chart

- The LiteLLM ClusterIP Service is not restricted by a LiteLLM ingress NetworkPolicy in v0.1.0. Other permitted in-cluster workloads could reach it if they know the service address and have the gateway key.
- The chart does not configure SSO, OIDC, per-user keys, or per-user quotas.
- The chart does not configure the ingress controller, TLS certificates, corporate firewall, VPN, or external secret manager.

## Required platform controls

- Keep the ingress controller and DNS route internal to the corporate network or VPN.
- Store the gateway and vLLM keys in the approved secret-management system.
- Give the shared v0.1.0 gateway key only to the small trusted pilot group.
- Add a LiteLLM ingress NetworkPolicy only after the ingress-controller namespace and labels are known. The policy must permit the real controller while denying unnecessary in-cluster callers.
- Move to per-user or per-service keys before broadening access beyond the trusted pilot.

## Future hardening phase

The next security phase should add an ingress-specific LiteLLM NetworkPolicy, identity-aware authentication, independently rotatable client keys, usage accounting, and quota policies.
