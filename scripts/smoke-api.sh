#!/usr/bin/env sh
set -eu

: "${LLM_BASE_URL:?Set LLM_BASE_URL, for example https://llm.internal.example/v1}"
: "${LITELLM_API_KEY:?Set LITELLM_API_KEY in the local environment}"

base_url="${LLM_BASE_URL%/}"

curl --fail --silent --show-error \
  --header "Authorization: Bearer ${LITELLM_API_KEY}" \
  "${base_url}/models" \
  > /dev/null

curl --fail --silent --show-error \
  --header "Authorization: Bearer ${LITELLM_API_KEY}" \
  --header "Content-Type: application/json" \
  --data '{"model":"company-code","messages":[{"role":"user","content":"Reply with exactly: smoke-ok"}],"max_tokens":8,"temperature":0}' \
  "${base_url}/chat/completions" \
  > /dev/null

echo "API smoke test passed."
