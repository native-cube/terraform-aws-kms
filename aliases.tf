resource "aws_kms_alias" "main" {
  count = local.create_legacy_alias ? 1 : 0

  region      = var.region
  name        = var.alias_name != null ? "alias/${var.alias_name}" : null
  name_prefix = var.alias_name_prefix != null ? "alias/${var.alias_name_prefix}" : null

  target_key_id = local.key_id
}

resource "aws_kms_alias" "additional" {
  for_each = var.create ? var.aliases : {}

  region      = var.region
  name        = each.value.name != null ? "alias/${each.value.name}" : null
  name_prefix = each.value.name_prefix != null ? "alias/${each.value.name_prefix}" : null

  target_key_id = local.key_id
}
