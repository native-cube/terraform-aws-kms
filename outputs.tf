output "key_arn" {
  value       = aws_kms_key.main.arn
  description = "KMS Key ARN."
}

output "key_id" {
  value       = aws_kms_key.main.key_id
  description = "KMS Key ID."
}

output "alias_arn" {
  value       = try(aws_kms_alias.main[0].arn, null)
  description = "KMS Key Alias ARN."
}

output "alias_name" {
  value       = try(aws_kms_alias.main[0].name, null)
  description = "KMS Key Alias name."
}

output "key_spec" {
  value       = local.key_spec
  description = "KMS Key spec."
}

output "tags_all" {
  value       = aws_kms_key.main.tags_all
  description = "Map of tags assigned to the KMS key, including provider default tags."
}
