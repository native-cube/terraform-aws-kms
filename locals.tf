locals {
  key_spec = coalesce(var.key_spec, var.customer_master_key_spec, "SYMMETRIC_DEFAULT")

  create_standard_key         = var.create && var.key_type == "standard"
  create_external_key         = var.create && var.key_type == "external"
  create_replica_key          = var.create && var.key_type == "replica"
  create_replica_external_key = var.create && var.key_type == "replica_external"
  create_legacy_alias         = var.create && (var.alias_name != null || var.alias_name_prefix != null)

  common_tags = var.tags

  key_arn = try(
    aws_kms_key.main[0].arn,
    aws_kms_external_key.main[0].arn,
    aws_kms_replica_key.main[0].arn,
    aws_kms_replica_external_key.main[0].arn,
    null,
  )

  key_id = try(
    aws_kms_key.main[0].key_id,
    aws_kms_external_key.main[0].id,
    aws_kms_replica_key.main[0].key_id,
    aws_kms_replica_external_key.main[0].key_id,
    null,
  )
}
