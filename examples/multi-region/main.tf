provider "aws" {
  region = "eu-west-1"
}

module "primary" {
  source = "../.."

  region       = "eu-west-1"
  description  = "Multi-Region primary KMS key"
  multi_region = true

  aliases = {
    primary = {
      name = "example/multi-region"
    }
  }

  tags = {
    Environment = "test"
  }
}

module "replica" {
  source = "../.."

  key_type        = "replica"
  region          = "eu-central-1"
  description     = "Multi-Region replica KMS key"
  primary_key_arn = module.primary.key_arn

  aliases = {
    replica = {
      name = "example/multi-region"
    }
  }

  tags = {
    Environment = "test"
  }
}
