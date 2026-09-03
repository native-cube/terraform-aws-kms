provider "aws" {
  region = "eu-west-1"
}

variable "key_material_base64" {
  description = "Base64-encoded 256-bit external key material. Supply through a secure workflow."
  type        = string
  sensitive   = true
}

module "kms" {
  source = "../.."

  key_type            = "external"
  description         = "External key material example"
  key_material_base64 = var.key_material_base64
  key_spec            = "SYMMETRIC_DEFAULT"

  aliases = {
    external = {
      name = "example/external"
    }
  }

  tags = {
    Environment = "test"
  }
}
