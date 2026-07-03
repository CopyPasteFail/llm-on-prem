#!/usr/bin/env sh
set -eu

chart_dir="${CHART_DIR:-charts/llm-serving}"
values_file="${VALUES_FILE:-${chart_dir}/values/gx10.yaml}"
namespace="${NAMESPACE:-llm-serving}"
output_dir="${OUTPUT_DIR:-rendered}"
manifest="${output_dir}/llm-serving.yaml"

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
  > "$manifest"

test -s "$manifest"
sh scripts/check-rendered-manifest.sh "$manifest"
echo "Rendered manifest: $manifest"
