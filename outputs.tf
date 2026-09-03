output "alias_arn" {
  description = "ARN of the legacy alias, or null when alias_name and alias_name_prefix are omitted."
  value       = try(aws_kms_alias.main[0].arn, null)
}

output "alias_name" {
  description = "Name of the legacy alias, or null when alias_name and alias_name_prefix are omitted."
  value       = try(aws_kms_alias.main[0].name, null)
}

output "alias_target_key_arn" {
  description = "Target key ARN of the legacy alias, or null when the legacy alias is not created."
  value       = try(aws_kms_alias.main[0].target_key_arn, null)
}

output "aliases" {
  description = "Additional aliases created by the module, keyed by the aliases input map key."
  value = {
    for name, alias in aws_kms_alias.additional : name => {
      arn            = alias.arn
      name           = alias.name
      target_key_arn = alias.target_key_arn
    }
  }
}

output "external_key_expiration_model" {
  description = "Expiration model of imported key material, or null for non-external keys."
  value = try(
    aws_kms_external_key.main[0].expiration_model,
    aws_kms_replica_external_key.main[0].expiration_model,
    null,
  )
}

output "external_key_state" {
  description = "State of the external KMS key, or null for non-external keys."
  value = try(
    aws_kms_external_key.main[0].key_state,
    aws_kms_replica_external_key.main[0].key_state,
    null,
  )
}

output "grants" {
  description = "KMS grants created by the module, keyed by the grants input map key."
  sensitive   = true
  value = {
    for name, grant in aws_kms_grant.main : name => {
      grant_id    = grant.grant_id
      grant_token = grant.grant_token
    }
  }
}

output "key_arn" {
  description = "ARN of the selected KMS key, or null when creation is disabled."
  value       = local.key_arn
}

output "key_id" {
  description = "ID of the selected KMS key, or null when creation is disabled."
  value       = local.key_id
}

output "key_policy" {
  description = "Policy reported for the selected KMS key, or null when creation is disabled."
  value = try(
    aws_kms_key.main[0].policy,
    aws_kms_external_key.main[0].policy,
    aws_kms_replica_key.main[0].policy,
    aws_kms_replica_external_key.main[0].policy,
    null,
  )
}

output "key_region" {
  description = "Region where the selected KMS key is managed, or null when creation is disabled."
  value = try(
    aws_kms_key.main[0].region,
    aws_kms_external_key.main[0].region,
    aws_kms_replica_key.main[0].region,
    aws_kms_replica_external_key.main[0].region,
    null,
  )
}

output "key_spec" {
  description = "Key spec of the selected KMS key, including the inherited spec for a replica."
  value = try(
    aws_kms_key.main[0].customer_master_key_spec,
    aws_kms_external_key.main[0].key_spec,
    aws_kms_replica_key.main[0].key_spec,
    local.create_replica_external_key ? null : local.key_spec,
    null,
  )
}

output "key_type" {
  description = "Selected KMS key resource type, or null when creation is disabled."
  value       = var.create ? var.key_type : null
}

output "key_usage" {
  description = "Cryptographic usage of the selected KMS key."
  value = try(
    aws_kms_key.main[0].key_usage,
    aws_kms_external_key.main[0].key_usage,
    aws_kms_replica_key.main[0].key_usage,
    aws_kms_replica_external_key.main[0].key_usage,
    null,
  )
}

output "tags_all" {
  description = "Tags assigned to the selected KMS key, including provider default tags."
  value = try(
    aws_kms_key.main[0].tags_all,
    aws_kms_external_key.main[0].tags_all,
    aws_kms_replica_key.main[0].tags_all,
    aws_kms_replica_external_key.main[0].tags_all,
    {},
  )
}
