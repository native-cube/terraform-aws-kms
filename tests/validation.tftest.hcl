mock_provider "aws" {
  override_during = plan
}

run "rejects_invalid_deletion_window" {
  command = plan

  variables {
    deletion_window_in_days = 31
  }

  expect_failures = [
    var.deletion_window_in_days
  ]
}

run "rejects_rotation_period_without_rotation" {
  command = plan

  variables {
    enable_key_rotation     = false
    rotation_period_in_days = 365
  }

  expect_failures = [
    var.rotation_period_in_days
  ]
}

run "rejects_invalid_rotation_period" {
  command = plan

  variables {
    rotation_period_in_days = 89
  }

  expect_failures = [
    var.rotation_period_in_days
  ]
}

run "rejects_alias_name_with_prefix" {
  command = plan

  variables {
    alias_name = "alias/unit-test"
  }

  expect_failures = [
    var.alias_name
  ]
}

run "rejects_conflicting_alias_inputs" {
  command = plan

  variables {
    alias_name        = "unit-test"
    alias_name_prefix = "unit-test-"
  }

  expect_failures = [
    var.alias_name
  ]
}

run "rejects_conflicting_key_spec_inputs" {
  command = plan

  variables {
    key_spec                 = "SYMMETRIC_DEFAULT"
    customer_master_key_spec = "HMAC_256"
  }

  expect_failures = [
    var.key_spec
  ]
}

run "rejects_xks_key_without_custom_key_store" {
  command = plan

  variables {
    xks_key_id = "xks-key-id"
  }

  expect_failures = [
    var.xks_key_id
  ]
}

run "rejects_invalid_key_type" {
  command = plan

  variables {
    key_type = "aws_owned"
  }

  expect_failures = [
    var.key_type
  ]
}

run "rejects_replica_without_primary" {
  command = plan

  variables {
    key_type = "replica"
  }

  expect_failures = [
    var.primary_key_arn
  ]
}

run "rejects_key_material_for_standard_key" {
  command = plan

  variables {
    key_material_base64 = "MDEyMzQ1Njc4OWFiY2RlZg=="
  }

  expect_failures = [
    var.key_material_base64
  ]
}

run "rejects_invalid_additional_alias" {
  command = plan

  variables {
    aliases = {
      invalid = {
        name        = "one"
        name_prefix = "two-"
      }
    }
  }

  expect_failures = [
    var.aliases
  ]
}

run "rejects_empty_grant_operations" {
  command = plan

  variables {
    grants = {
      invalid = {
        grantee_principal = "arn:aws:iam::123456789012:role/application"
        operations        = []
      }
    }
  }

  expect_failures = [
    var.grants
  ]
}
