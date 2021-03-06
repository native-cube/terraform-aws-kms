output "key_arn" {
  value       = aws_kms_key.main.arn
  description = "KMS Key ARN."
}

output "key_id" {
  value       = aws_kms_key.main.key_id
  description = "KMS Key ID."
}

output "alias_arn" {
  value       = aws_kms_alias.main.arn
  description = "KMS Key Alias ARN."
}

output "alias_name" {
  value       = aws_kms_alias.main.name
  description = "KMS Key Alias name."
}
