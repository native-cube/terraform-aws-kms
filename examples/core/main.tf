provider "aws" {
  region = "eu-west-1"
}

module "kms" {
  source = "../.."

  description             = "KMS test description"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  key_spec                = "SYMMETRIC_DEFAULT"
  rotation_period_in_days = 365

  aliases = {
    primary = {
      name = "test-key"
    }
    application = {
      name = "test-key/application"
    }
  }

  tags = {
    Environment = "test"
  }
}
