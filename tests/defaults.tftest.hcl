mock_provider "aws" {
  override_during = plan
}

run "default_key_without_alias" {
  command = plan

  assert {
    condition     = length(aws_kms_key.main) == 1
    error_message = "The module should create one standard KMS key by default."
  }

  assert {
    condition     = aws_kms_key.main[0].description == "Parameter Store KMS key"
    error_message = "The default key description should be used when description is omitted."
  }

  assert {
    condition     = aws_kms_key.main[0].key_usage == "ENCRYPT_DECRYPT"
    error_message = "The default key usage should be ENCRYPT_DECRYPT."
  }

  assert {
    condition     = aws_kms_key.main[0].customer_master_key_spec == "SYMMETRIC_DEFAULT"
    error_message = "The default key spec should be SYMMETRIC_DEFAULT."
  }

  assert {
    condition     = aws_kms_key.main[0].deletion_window_in_days == 10
    error_message = "The default deletion window should be 10 days."
  }

  assert {
    condition     = aws_kms_key.main[0].enable_key_rotation == true
    error_message = "Key rotation should be enabled by default."
  }

  assert {
    condition     = aws_kms_key.main[0].multi_region == false
    error_message = "The key should be regional by default."
  }

  assert {
    condition     = length(aws_kms_alias.main) == 0
    error_message = "The module should not create an alias when alias inputs are omitted."
  }

  assert {
    condition = (
      length(aws_kms_external_key.main) == 0 &&
      length(aws_kms_replica_key.main) == 0 &&
      length(aws_kms_replica_external_key.main) == 0 &&
      length(aws_kms_alias.additional) == 0 &&
      length(aws_kms_grant.main) == 0
    )
    error_message = "Optional key types, additional aliases, and grants should not be created by default."
  }
}

run "creation_disabled" {
  command = plan

  variables {
    create = false
  }

  assert {
    condition = (
      length(aws_kms_key.main) == 0 &&
      length(aws_kms_external_key.main) == 0 &&
      length(aws_kms_replica_key.main) == 0 &&
      length(aws_kms_replica_external_key.main) == 0
    )
    error_message = "No KMS key should be created when create is false."
  }

  assert {
    condition     = output.key_id == null && output.key_arn == null && output.key_type == null
    error_message = "Key outputs should be null when creation is disabled."
  }
}
