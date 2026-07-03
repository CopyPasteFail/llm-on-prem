# Quotas and Identity

## v0.1.0 implemented scope

Version 0.1.0 runs LiteLLM without a database and exposes one stable model alias, `company-code`.

The implemented authentication boundary is one gateway key:

```text
Client
  -> Authorization: Bearer LITELLM_MASTER_KEY
  -> LiteLLM
  -> private vLLM service
```

This is suitable for a small trusted internal pilot. It is not per-user identity, per-service identity, SSO, persistent usage accounting, virtual-key management, or quota enforcement.

## What v0.1.0 does provide

- A gateway key protects the LiteLLM API.
- vLLM is private to the namespace and receives traffic only from LiteLLM.
- The stable `company-code` alias avoids client changes during model replacement.
- vLLM context, batching, and concurrent-sequence limits protect the single GX10 from unbounded model settings.

## What v0.1.0 does not provide

- Individual human identities.
- SSO or OIDC login.
- Separate service keys.
- Per-user, per-team, or per-service quotas.
- Persistent usage, spend, or audit accounting.
- Self-service key creation.
- Multiple model-access tiers.

Do not describe the initial master key as a personal key. Store it in the approved secret-management system and distribute it only to the limited pilot clients that need access.

## Security rule

Never commit `LITELLM_MASTER_KEY` or `VLLM_API_KEY`. The chart references the pre-existing `llm-serving-secrets` Secret; it does not create populated secrets.

## Future identity and quota phase

Add a separate, reviewed phase when the service needs multiple users or services with independent access policy. That phase should include:

1. A managed PostgreSQL database or another supported persistence path for LiteLLM.
2. A gateway identity design: SSO/OIDC for people and service identities for automation.
3. Per-client LiteLLM virtual keys with model access, expiry, rate, concurrency, and token limits.
4. Usage/audit retention policy and dashboarding.
5. Key issuance, rotation, revocation, and approval workflow.
6. Migration away from the shared pilot master key.

Until that phase exists, the operational boundary is a trusted internal pilot with one shared gateway credential and one model alias.
