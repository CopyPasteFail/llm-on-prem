#!/usr/bin/env sh
set -eu

require_file() {
  test -f "$1" || {
    echo "ERROR: required file is missing: $1" >&2
    exit 1
  }
}

require_text() {
  file="$1"
  pattern="$2"
  description="$3"
  if ! grep -Eq "$pattern" "$file"; then
    echo "ERROR: expected ${description} in ${file}" >&2
    exit 1
  fi
}

require_file charts/llm-serving/values/gx10.yaml
require_file argocd/llm-serving.application.example.yaml
require_file argocd/llm-serving.project.example.yaml
require_file docs/decisions/0001-v0.1.0-one-active-model.md
require_file docs/decisions/0002-k3s-and-gpu-operator.md

require_text charts/llm-serving/values/gx10.yaml 'servedModelName: company-code' 'the stable company-code alias'
require_text charts/llm-serving/values/gx10.yaml 'trustRemoteCode: false' 'trustRemoteCode disabled'
require_text argocd/llm-serving.application.example.yaml 'project: llm-serving' 'the dedicated Argo CD project'
require_text argocd/llm-serving.application.example.yaml 'prune: false' 'pruning disabled for v0.1.0'
require_text argocd/llm-serving.project.example.yaml 'namespace: llm-serving' 'the restricted destination namespace'

if grep -Eq 'LITELLM_MASTER_KEY: [^R]|VLLM_API_KEY: [^R]' examples/llm-serving-secrets.example.yaml; then
  echo "ERROR: the example Secret appears to contain a populated credential." >&2
  exit 1
fi

echo "GitOps configuration guard checks passed."
