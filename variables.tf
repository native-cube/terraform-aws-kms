variable "region" {
  type        = string
  default     = null
  description = "Region where the KMS key and alias are managed. Defaults to the provider region."
}

variable "description" {
  type        = string
  default     = "Parameter Store KMS key"
  description = "Description of the KMS key as viewed in the AWS console."
}

variable "key_usage" {
  type        = string
  default     = "ENCRYPT_DECRYPT"
  description = "Intended cryptographic use of the KMS key."

  validation {
    condition     = contains(["ENCRYPT_DECRYPT", "SIGN_VERIFY", "GENERATE_VERIFY_MAC"], var.key_usage)
    error_message = "key_usage must be one of ENCRYPT_DECRYPT, SIGN_VERIFY, or GENERATE_VERIFY_MAC."
  }
}

variable "key_spec" {
  type        = string
  default     = null
  description = "Specifies whether the KMS key contains a symmetric key, asymmetric key pair, HMAC key, SM2 key, ML-DSA key, or Ed25519 key. Defaults to SYMMETRIC_DEFAULT."

  validation {
    condition = var.key_spec == null || contains([
      "SYMMETRIC_DEFAULT",
      "HMAC_224",
      "HMAC_256",
      "HMAC_384",
      "HMAC_512",
      "SM2",
      "RSA_2048",
      "RSA_3072",
      "RSA_4096",
      "ECC_NIST_P256",
      "ECC_NIST_P384",
      "ECC_NIST_P521",
      "ECC_SECG_P256K1",
      "ECC_NIST_EDWARDS25519",
      "ML_DSA_44",
      "ML_DSA_65",
      "ML_DSA_87"
    ], var.key_spec)
    error_message = "key_spec must be a valid AWS KMS key spec."
  }

  validation {
    condition     = var.key_spec == null || var.customer_master_key_spec == null
    error_message = "Use key_spec or customer_master_key_spec, not both."
  }
}

variable "customer_master_key_spec" {
  type        = string
  default     = null
  description = "Deprecated compatibility input for key_spec. Prefer key_spec for new configurations."

  validation {
    condition = var.customer_master_key_spec == null || contains([
      "SYMMETRIC_DEFAULT",
      "HMAC_224",
      "HMAC_256",
      "HMAC_384",
      "HMAC_512",
      "SM2",
      "RSA_2048",
      "RSA_3072",
      "RSA_4096",
      "ECC_NIST_P256",
      "ECC_NIST_P384",
      "ECC_NIST_P521",
      "ECC_SECG_P256K1",
      "ECC_NIST_EDWARDS25519",
      "ML_DSA_44",
      "ML_DSA_65",
      "ML_DSA_87"
    ], var.customer_master_key_spec)
    error_message = "customer_master_key_spec must be a valid AWS KMS key spec."
  }
}

variable "custom_key_store_id" {
  type        = string
  default     = null
  description = "ID of the CloudHSM key store or external key store where the KMS key is created."
}

variable "deletion_window_in_days" {
  type        = number
  default     = 10
  description = "Duration in days after which the key is deleted after destruction of the resource."

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "deletion_window_in_days must be between 7 and 30 days."
  }
}

variable "is_enabled" {
  type        = bool
  default     = true
  description = "Specifies whether the key is enabled."
}

variable "enable_key_rotation" {
  type        = bool
  default     = true
  description = "Specifies whether key rotation is enabled."
}

variable "rotation_period_in_days" {
  type        = number
  default     = null
  description = "Number of days between automatic key rotations. Valid values are 90 through 2560. Only used when enable_key_rotation is true."

  validation {
    condition     = var.rotation_period_in_days == null || (var.rotation_period_in_days >= 90 && var.rotation_period_in_days <= 2560)
    error_message = "rotation_period_in_days must be null or between 90 and 2560 days."
  }

  validation {
    condition     = var.rotation_period_in_days == null || var.enable_key_rotation
    error_message = "rotation_period_in_days can only be set when enable_key_rotation is true."
  }
}

variable "create_timeout" {
  type        = string
  default     = null
  description = "Custom timeout for KMS key creation, for example 5m. Defaults to the provider timeout."
}

variable "policy" {
  type        = string
  default     = null
  description = "A valid KMS key policy JSON document."

  validation {
    condition     = var.policy == null || can(jsondecode(var.policy))
    error_message = "policy must be null or a valid JSON document."
  }
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Mapping of additional tags."
}

variable "alias_name" {
  type        = string
  description = "The display name of the alias."
  default     = null

  validation {
    condition     = var.alias_name == null || var.alias_name_prefix == null
    error_message = "alias_name conflicts with alias_name_prefix."
  }

  validation {
    condition     = var.alias_name == null || !startswith(var.alias_name, "alias/")
    error_message = "alias_name must not include the alias/ prefix."
  }
}

variable "alias_name_prefix" {
  type        = string
  description = "Creates an unique alias beginning with the specified prefix. Conflicts with alias_name."
  default     = null

  validation {
    condition     = var.alias_name_prefix == null || !startswith(var.alias_name_prefix, "alias/")
    error_message = "alias_name_prefix must not include the alias/ prefix."
  }
}

variable "bypass_policy_lockout_safety_check" {
  type        = bool
  default     = false
  description = "Specifies whether to disable the policy lockout check performed when creating or updating the key's policy."
}

variable "multi_region" {
  type        = bool
  description = "Indicates whether the KMS key is a multi-Region (true) or regional (false) key."
  default     = false
}

variable "xks_key_id" {
  type        = string
  description = "ID of the external key that serves as key material for an external key store KMS key."
  default     = null

  validation {
    condition     = var.xks_key_id == null || var.custom_key_store_id != null
    error_message = "xks_key_id can only be set with custom_key_store_id."
  }
}
