resource "aws_kms_replica_key" "main" {
  count = local.create_replica_key ? 1 : 0

  region                             = var.region
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
  deletion_window_in_days            = var.deletion_window_in_days
  description                        = var.description
  enabled                            = var.is_enabled
  policy                             = var.policy
  primary_key_arn                    = var.primary_key_arn
  tags                               = local.common_tags
}
