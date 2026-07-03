# Secret Handling

## Rule

Desired state belongs in Git. Credentials do not.

The tracked GX10 values file contains model selection, image digests, capacity settings, ingress configuration, and optional Secret names. It must not contain API keys, registry passwords, certificates, database passwords, or Hugging Face tokens.

## Application gateway secret

The Helm chart expects an existing Secret named by:

```yaml
litellm:
  existingSecret:
    name: llm-serving-secrets
```

Required keys:

| Key | Used by | Purpose |
|---|---|---|
| `LITELLM_MASTER_KEY` | LiteLLM | Shared gateway authentication for the trusted v0.1.0 pilot |
| `VLLM_API_KEY` | LiteLLM and vLLM | Private LiteLLM-to-vLLM authentication |

`examples/llm-serving-secrets.example.yaml` documents only the key shape. Do not populate or apply that file unchanged.

## Private registry image-pull secret

When LiteLLM or vLLM images come from a private GitLab Container Registry, create an image-pull Secret outside Git through the approved platform process.

Reference its name, but never its credential data, in `charts/llm-serving/values/gx10.yaml`:

```yaml
imagePullSecrets:
  - name: llm-serving-registry
```

The chart adds this reference to both application pods. The Argo CD project deliberately blocks application-managed Secret resources, so the pull Secret must be created by the platform or external secret-management process before the first synchronization.

## Optional Hugging Face token

Public models do not need this. For an approved private or gated Hugging Face model, create an external Secret containing `HF_TOKEN` and reference only its name and key:

```yaml
vllm:
  huggingFaceToken:
    secretName: llm-serving-huggingface
    secretKey: HF_TOKEN
```

When `secretName` is empty, the chart does not inject `HF_TOKEN`. The token value stays outside Git. Hugging Face documents `HF_TOKEN` as the environment variable used to authenticate Hub access. citeturn966445view0

## Optional database key

`DATABASE_URL` is required only when database-backed LiteLLM features are deliberately enabled. The v0.1.0 chart does not create a database and does not implement per-user identity or quota features.

## Argo CD and GitLab credentials

Argo CD repository credentials and GitLab registry credentials are platform-managed credentials. Store them through the approved platform secret-management process, not in this application repository.

## Rotation

Rotate a secret by updating the external Secret, then restarting or reconciling the affected workload according to the approved platform process. Record the rotation event without recording the secret value.
