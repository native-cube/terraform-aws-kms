resource "aws_kms_grant" "main" {
  for_each = var.create ? var.grants : {}

  region                = var.region
  grant_creation_tokens = each.value.grant_creation_tokens
  grantee_principal     = each.value.grantee_principal
  key_id                = local.key_id
  name                  = coalesce(each.value.name, each.key)
  operations            = each.value.operations
  retire_on_delete      = each.value.retire_on_delete
  retiring_principal    = each.value.retiring_principal

  dynamic "constraints" {
    for_each = each.value.constraints

    content {
      encryption_context_equals = constraints.value.encryption_context_equals
      encryption_context_subset = constraints.value.encryption_context_subset
    }
  }
}
