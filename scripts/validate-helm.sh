#!/usr/bin/env sh
set -eu

chart_dir="${CHART_DIR:-charts/llm-serving}"
values_file="${VALUES_FILE:-${chart_dir}/values/gx10.yaml}"
namespace="${NAMESPACE:-llm-serving}"
output_dir="${OUTPUT_DIR:-rendered}"

command -v helm >/dev/null 2>&1 || {
  echo "ERROR: helm is required on PATH." >&2
  exit 1
}

test -f "$values_file" || {
  echo "ERROR: values file not found: $values_file" >&2
  exit 1
}

mkdir -p "$output_dir"
helm lint "$chart_dir" --values "$values_file"
helm template llm-serving "$chart_dir" \
  --namespace "$namespace" \
  --values "$values_file" \
  > "$output_dir/llm-serving.yaml"

test -s "$output_dir/llm-serving.yaml"
echo "Rendered manifest: $output_dir/llm-serving.yaml"
