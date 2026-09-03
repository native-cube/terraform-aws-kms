mock_provider "aws" {
  override_during = plan
}

run "external_key" {
  command = plan

  variables {
    key_type            = "external"
    key_material_base64 = "MDEyMzQ1Njc4OWFiY2RlZg=="
    key_spec            = "SYMMETRIC_DEFAULT"
    multi_region        = true
    valid_to            = "2035-01-01T00:00:00Z"
    alias_name          = "external"
  }

  assert {
    condition = (
      length(aws_kms_key.main) == 0 &&
      length(aws_kms_external_key.main) == 1 &&
      aws_kms_external_key.main[0].key_material_base64 == "MDEyMzQ1Njc4OWFiY2RlZg==" &&
      aws_kms_external_key.main[0].valid_to == "2035-01-01T00:00:00Z" &&
      aws_kms_external_key.main[0].multi_region == true
    )
    error_message = "The external key type should wire all imported-material arguments."
  }
}

run "replica_key" {
  command = plan

  variables {
    key_type        = "replica"
    primary_key_arn = "arn:aws:kms:us-east-1:123456789012:key/mrk-1234567890abcdef"
    region          = "eu-west-1"
    policy          = jsonencode({ Version = "2012-10-17", Statement = [] })
  }

  assert {
    condition = (
      length(aws_kms_key.main) == 0 &&
      length(aws_kms_replica_key.main) == 1 &&
      aws_kms_replica_key.main[0].primary_key_arn == "arn:aws:kms:us-east-1:123456789012:key/mrk-1234567890abcdef" &&
      aws_kms_replica_key.main[0].region == "eu-west-1"
    )
    error_message = "The replica key type should create an AWS-managed-material replica."
  }
}

run "replica_external_key" {
  command = plan

  variables {
    key_type            = "replica_external"
    primary_key_arn     = "arn:aws:kms:us-east-1:123456789012:key/mrk-abcdef1234567890"
    region              = "eu-west-1"
    key_material_base64 = "MDEyMzQ1Njc4OWFiY2RlZg=="
    valid_to            = "2035-01-01T00:00:00Z"
  }

  assert {
    condition = (
      length(aws_kms_replica_key.main) == 0 &&
      length(aws_kms_replica_external_key.main) == 1 &&
      aws_kms_replica_external_key.main[0].primary_key_arn == "arn:aws:kms:us-east-1:123456789012:key/mrk-abcdef1234567890" &&
      aws_kms_replica_external_key.main[0].key_material_base64 == "MDEyMzQ1Njc4OWFiY2RlZg=="
    )
    error_message = "The replica_external key type should create an imported-material replica."
  }
}
