#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SCHEMA_FILE="$(mktemp)"
trap 'rm -f "$SCHEMA_FILE"' EXIT

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required to check AWS provider argument coverage." >&2
  exit 127
fi

terraform -chdir="$ROOT_DIR" providers schema -json >"$SCHEMA_FILE"

check_resource() {
  local resource_name="$1"
  local resource_file="$2"
  local missing

  missing="$({
    jq -r --arg resource "$resource_name" '
      def configurable_arguments:
        ((.attributes // {}) | to_entries[] |
          select((.value.required == true or .value.optional == true) and
                 (.key != "id" and .key != "tags_all")) | .key),
        ((.block_types // {}) | to_entries[] | .key, (.value.block | configurable_arguments));
      .provider_schemas["registry.terraform.io/hashicorp/aws"]
        .resource_schemas[$resource].block | configurable_arguments
    ' "$SCHEMA_FILE" | sort -u
  } | comm -23 - <(
    awk '
      /^[[:space:]]+[a-z0-9_]+[[:space:]]*=/ {
        name = $1
        print name
      }
      /^[[:space:]]+dynamic "/ {
        name = $2
        gsub(/"/, "", name)
        print name
      }
      /^[[:space:]]+[a-z0-9_]+[[:space:]]*\{/ {
        name = $1
        print name
      }
    ' "$ROOT_DIR/$resource_file" | sort -u
  ))"

  if [[ -n "$missing" ]]; then
    echo "$resource_name is missing provider arguments:" >&2
    echo "$missing" >&2
    return 1
  fi

  echo "$resource_name: all configurable arguments are wired"
}

check_resource "aws_kms_key" "key.tf"
check_resource "aws_kms_external_key" "external_key.tf"
check_resource "aws_kms_replica_key" "replica_key.tf"
check_resource "aws_kms_replica_external_key" "replica_external_key.tf"
check_resource "aws_kms_alias" "aliases.tf"
check_resource "aws_kms_grant" "grants.tf"
