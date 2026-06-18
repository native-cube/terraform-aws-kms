locals {
  key_spec     = coalesce(var.key_spec, var.customer_master_key_spec, "SYMMETRIC_DEFAULT")
  create_alias = var.alias_name != null || var.alias_name_prefix != null
}

resource "aws_kms_key" "main" {
  region                             = var.region
  description                        = var.description
  key_usage                          = var.key_usage
  customer_master_key_spec           = local.key_spec
  custom_key_store_id                = var.custom_key_store_id
  deletion_window_in_days            = var.deletion_window_in_days
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  is_enabled                         = var.is_enabled
  enable_key_rotation                = var.enable_key_rotation
  rotation_period_in_days            = var.rotation_period_in_days
  xks_key_id                         = var.xks_key_id
  policy                             = var.policy
  multi_region                       = var.multi_region

  tags = var.tags

  timeouts {
    create = var.create_timeout
  }
}

resource "aws_kms_alias" "main" {
  count = local.create_alias ? 1 : 0

  region      = var.region
  name        = var.alias_name != null ? "alias/${var.alias_name}" : null
  name_prefix = var.alias_name_prefix != null ? "alias/${var.alias_name_prefix}" : null

  target_key_id = aws_kms_key.main.key_id
}
