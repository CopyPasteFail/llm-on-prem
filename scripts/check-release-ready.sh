#!/usr/bin/env sh
set -eu

values_file="${1:-charts/llm-serving/values/gx10.yaml}"

test -f "$values_file" || {
  echo "ERROR: values file not found: $values_file" >&2
  exit 1
}

forbid() {
  pattern="$1"
  description="$2"
  if grep -Eq -- "$pattern" "$values_file"; then
    echo "ERROR: release is not ready: ${description}" >&2
    exit 1
  fi
}

forbid 'registry\.example\.internal' 'example image repository remains'
forbid 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa' 'example LiteLLM image digest remains'
forbid 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb' 'example vLLM image digest remains'
forbid '0123456789abcdef0123456789abcdef01234567' 'example model revision remains'
forbid 'llm\.internal\.example' 'example ingress hostname remains'
forbid 'REPLACE_WITH_' 'placeholder release value remains'

echo "Release readiness checks passed for: $values_file"
