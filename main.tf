resource "aws_kms_key" "main" {
  description                        = var.description
  key_usage                          = var.key_usage
  customer_master_key_spec           = var.customer_master_key_spec
  deletion_window_in_days            = var.deletion_window_in_days
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  is_enabled                         = var.is_enabled
  enable_key_rotation                = var.enable_key_rotation
  policy                             = var.policy != "" ? var.policy : null
  multi_region                       = var.multi_region

  tags = var.tags
}

resource "aws_kms_alias" "main" {
  name        = var.alias_name != null ? "alias/${var.alias_name}" : null
  name_prefix = var.alias_name_prefix != null ? "alias/${var.alias_name_prefix}" : null

  target_key_id = aws_kms_key.main.id
}
