mock_provider "aws" {
  override_during = plan
}

run "default_key_without_alias" {
  command = plan

  assert {
    condition     = aws_kms_key.main.description == "Parameter Store KMS key"
    error_message = "The default key description should be used when description is omitted."
  }

  assert {
    condition     = aws_kms_key.main.key_usage == "ENCRYPT_DECRYPT"
    error_message = "The default key usage should be ENCRYPT_DECRYPT."
  }

  assert {
    condition     = aws_kms_key.main.customer_master_key_spec == "SYMMETRIC_DEFAULT"
    error_message = "The default key spec should be SYMMETRIC_DEFAULT."
  }

  assert {
    condition     = aws_kms_key.main.deletion_window_in_days == 10
    error_message = "The default deletion window should be 10 days."
  }

  assert {
    condition     = aws_kms_key.main.enable_key_rotation == true
    error_message = "Key rotation should be enabled by default."
  }

  assert {
    condition     = aws_kms_key.main.multi_region == false
    error_message = "The key should be regional by default."
  }

  assert {
    condition     = length(aws_kms_alias.main) == 0
    error_message = "The module should not create an alias when alias inputs are omitted."
  }
}
