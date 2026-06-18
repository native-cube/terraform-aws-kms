#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECK_MODE=false

if [[ "${1:-}" == "--check" ]]; then
  CHECK_MODE=true
elif [[ "${1:-}" != "" ]]; then
  echo "Usage: $0 [--check]" >&2
  exit 2
fi

if ! command -v terraform-docs >/dev/null 2>&1; then
  echo "terraform-docs is required. Install it with: brew install terraform-docs" >&2
  exit 127
fi

if [[ "$CHECK_MODE" == true ]]; then
  terraform-docs --lockfile=false markdown table --config "$ROOT_DIR/.terraform-docs.yml" --output-check "$ROOT_DIR"
else
  terraform-docs --lockfile=false markdown table --config "$ROOT_DIR/.terraform-docs.yml" "$ROOT_DIR"
fi
