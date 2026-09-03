resource "aws_kms_external_key" "main" {
  count = local.create_external_key ? 1 : 0

  region                             = var.region
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  deletion_window_in_days            = var.deletion_window_in_days
  description                        = var.description
  enabled                            = var.is_enabled
  key_material_base64                = var.key_material_base64
  key_spec                           = local.key_spec
  key_usage                          = var.key_usage
  multi_region                       = var.multi_region
  policy                             = var.policy
  tags                               = local.common_tags
  valid_to                           = var.valid_to
}
