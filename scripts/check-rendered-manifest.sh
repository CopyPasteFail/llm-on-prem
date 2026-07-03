#!/usr/bin/env sh
set -eu

manifest="${1:-rendered/llm-serving.yaml}"

test -s "$manifest" || {
  echo "ERROR: rendered manifest not found or empty: $manifest" >&2
  exit 1
}

require() {
  pattern="$1"
  description="$2"
  if ! grep -Eq "$pattern" "$manifest"; then
    echo "ERROR: expected ${description}" >&2
    exit 1
  fi
}

require 'kind: Deployment' 'Deployment resources'
require 'name: llm-serving-vllm' 'the vLLM deployment'
require 'type: Recreate' 'the vLLM Recreate strategy'
require 'nvidia.com/gpu: 1' 'a full GPU limit'
require 'kind: NetworkPolicy' 'the vLLM network policy'
require 'kind: PersistentVolumeClaim' 'the model cache PVC'
require 'name: llm-serving-vllm' 'the private vLLM service'

if grep -Eq 'REPLACE_WITH_|registry\.example\.internal' "$manifest"; then
  echo "WARNING: rendered manifest still contains example release values." >&2
fi

echo "Rendered manifest guard checks passed."
