# Secret Handling

## Rule

Desired state belongs in Git. Credentials do not.

The tracked GX10 values file contains model selection, image digests, capacity settings, and ingress configuration. It must not contain API keys, registry passwords, certificates, database passwords, or Hugging Face tokens.

## Required secret

The Helm chart expects an existing Secret named by:

```yaml
litellm:
  existingSecret:
    name: llm-serving-secrets
```

Required keys:

| Key | Used by | Purpose |
|---|---|---|
| `LITELLM_MASTER_KEY` | LiteLLM | Gateway authentication |
| `VLLM_API_KEY` | LiteLLM and vLLM | Private LiteLLM-to-vLLM authentication |

`examples/llm-serving-secrets.example.yaml` documents only the key shape. Do not populate or apply that file unchanged.

## Optional database key

`DATABASE_URL` is required only if database-backed LiteLLM features are deliberately enabled, such as managed virtual keys and persistent user or team policy. The v0.1.0 chart does not create a database.

## Argo CD and GitLab credentials

Argo CD repository credentials and GitLab registry credentials are platform-managed credentials. Store them through the approved platform secret-management process, not in this application repository.

## Rotation

Rotate a secret by updating the external Secret, then restarting or reconciling the affected workload according to the approved platform process. Record the rotation event without recording the secret value.
