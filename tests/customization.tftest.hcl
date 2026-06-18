mock_provider "aws" {
  override_during = plan
}

run "custom_key_with_alias" {
  command = plan

  variables {
    region                  = "eu-west-1"
    description             = "Unit test key"
    alias_name              = "unit-test"
    deletion_window_in_days = 30
    enable_key_rotation     = true
    rotation_period_in_days = 365
    key_spec                = "SYMMETRIC_DEFAULT"
    multi_region            = true
    create_timeout          = "5m"

    tags = {
      Environment = "test"
      Owner       = "platform"
    }
  }

  assert {
    condition     = aws_kms_key.main.region == "eu-west-1"
    error_message = "The KMS key should use the configured resource region."
  }

  assert {
    condition     = aws_kms_key.main.description == "Unit test key"
    error_message = "The KMS key should use the configured description."
  }

  assert {
    condition     = aws_kms_key.main.deletion_window_in_days == 30
    error_message = "The KMS key should use the configured deletion window."
  }

  assert {
    condition     = aws_kms_key.main.rotation_period_in_days == 365
    error_message = "The KMS key should use the configured rotation period."
  }

  assert {
    condition     = aws_kms_key.main.multi_region == true
    error_message = "The KMS key should support multi-Region primary keys."
  }

  assert {
    condition     = aws_kms_key.main.tags.Environment == "test"
    error_message = "The KMS key should include configured tags."
  }

  assert {
    condition     = length(aws_kms_alias.main) == 1
    error_message = "The module should create one alias when alias_name is configured."
  }

  assert {
    condition     = aws_kms_alias.main[0].region == "eu-west-1"
    error_message = "The KMS alias should use the configured resource region."
  }

  assert {
    condition     = aws_kms_alias.main[0].name == "alias/unit-test"
    error_message = "The KMS alias name should include the alias/ prefix."
  }
}

run "custom_hmac_key_with_alias_prefix" {
  command = plan

  variables {
    description             = "Unit HMAC key"
    alias_name_prefix       = "unit-hmac-"
    deletion_window_in_days = 7
    enable_key_rotation     = false
    key_usage               = "GENERATE_VERIFY_MAC"
    key_spec                = "HMAC_256"
  }

  assert {
    condition     = aws_kms_key.main.key_usage == "GENERATE_VERIFY_MAC"
    error_message = "The KMS key should support HMAC key usage."
  }

  assert {
    condition     = aws_kms_key.main.customer_master_key_spec == "HMAC_256"
    error_message = "The KMS key should support HMAC key specs."
  }

  assert {
    condition     = aws_kms_key.main.enable_key_rotation == false
    error_message = "Key rotation should be configurable."
  }

  assert {
    condition     = aws_kms_alias.main[0].name_prefix == "alias/unit-hmac-"
    error_message = "The KMS alias prefix should include the alias/ prefix."
  }
}
