resource "aws_kms_key" "main" {
  count = local.create_standard_key ? 1 : 0

  region                             = var.region
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  customer_master_key_spec           = local.key_spec
  custom_key_store_id                = var.custom_key_store_id
  deletion_window_in_days            = var.deletion_window_in_days
  description                        = var.description
  enable_key_rotation                = var.enable_key_rotation
  is_enabled                         = var.is_enabled
  key_usage                          = var.key_usage
  multi_region                       = var.multi_region
  policy                             = var.policy
  rotation_period_in_days            = var.rotation_period_in_days
  tags                               = local.common_tags
  xks_key_id                         = var.xks_key_id

  timeouts {
    create = var.create_timeout
  }
}

moved {
  from = aws_kms_key.main
  to   = aws_kms_key.main[0]
}
