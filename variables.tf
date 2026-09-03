variable "alias_name" {
  description = "Legacy exact alias name to create without the alias/ prefix. Prefer aliases for new configurations."
  type        = string
  default     = null

  validation {
    condition     = var.alias_name == null || (trimspace(var.alias_name) != "" && !startswith(var.alias_name, "alias/"))
    error_message = "alias_name must be null or a non-empty name without the alias/ prefix."
  }

  validation {
    condition     = var.alias_name == null || var.alias_name_prefix == null
    error_message = "alias_name conflicts with alias_name_prefix."
  }
}

variable "alias_name_prefix" {
  description = "Legacy alias name prefix to create without the alias/ prefix. Prefer aliases for new configurations."
  type        = string
  default     = null

  validation {
    condition     = var.alias_name_prefix == null || (trimspace(var.alias_name_prefix) != "" && !startswith(var.alias_name_prefix, "alias/"))
    error_message = "alias_name_prefix must be null or a non-empty prefix without the alias/ prefix."
  }
}

variable "aliases" {
  description = "Additional KMS aliases keyed by a stable Terraform key. Set exactly one of name or name_prefix and omit the alias/ prefix."
  type = map(object({
    name        = optional(string)
    name_prefix = optional(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for alias in values(var.aliases) :
      (alias.name == null) != (alias.name_prefix == null)
    ])
    error_message = "Each aliases entry must set exactly one of name or name_prefix."
  }

  validation {
    condition = alltrue(flatten([
      for alias in values(var.aliases) : [
        alias.name == null ? true : trimspace(alias.name) != "" && !startswith(alias.name, "alias/"),
        alias.name_prefix == null ? true : trimspace(alias.name_prefix) != "" && !startswith(alias.name_prefix, "alias/"),
      ]
    ]))
    error_message = "Alias names and prefixes must be non-empty and must not include the alias/ prefix."
  }
}

variable "bypass_policy_lockout_safety_check" {
  description = "Whether to bypass the policy lockout safety check. Enabling this can make the KMS key unmanageable."
  type        = bool
  default     = false
}

variable "create" {
  description = "Whether to create the selected KMS key, aliases, and grants."
  type        = bool
  default     = true
}

variable "create_timeout" {
  description = "Optional custom creation timeout for a standard KMS key, for example 5m."
  type        = string
  default     = null

  validation {
    condition     = var.create_timeout == null || var.key_type == "standard"
    error_message = "create_timeout applies only when key_type is standard."
  }
}

variable "custom_key_store_id" {
  description = "ID of an existing CloudHSM or external custom key store for a standard key."
  type        = string
  default     = null

  validation {
    condition     = var.custom_key_store_id == null || var.key_type == "standard"
    error_message = "custom_key_store_id applies only when key_type is standard."
  }
}

variable "customer_master_key_spec" {
  description = "Deprecated compatibility input for key_spec. Prefer key_spec for new configurations."
  type        = string
  default     = null

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
      "ML_DSA_87",
    ], var.customer_master_key_spec)
    error_message = "customer_master_key_spec must be a valid AWS KMS key spec."
  }

  validation {
    condition     = var.customer_master_key_spec == null || var.key_type == "standard"
    error_message = "customer_master_key_spec applies only when key_type is standard."
  }
}

variable "deletion_window_in_days" {
  description = "Waiting period in days before AWS KMS permanently deletes the key."
  type        = number
  default     = 10

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "deletion_window_in_days must be between 7 and 30 days."
  }
}

variable "description" {
  description = "Description of the KMS key."
  type        = string
  default     = "Parameter Store KMS key"
}

variable "enable_key_rotation" {
  description = "Whether automatic rotation is enabled for a standard KMS key."
  type        = bool
  default     = true
}

variable "grants" {
  description = "KMS grants to create for the selected key, keyed by a stable Terraform key."
  type = map(object({
    grantee_principal     = string
    operations            = set(string)
    name                  = optional(string)
    grant_creation_tokens = optional(set(string), [])
    retire_on_delete      = optional(bool)
    retiring_principal    = optional(string)
    constraints = optional(list(object({
      encryption_context_equals = optional(map(string))
      encryption_context_subset = optional(map(string))
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for name, grant in var.grants :
      trimspace(name) != "" &&
      trimspace(grant.grantee_principal) != "" &&
      length(grant.operations) > 0 &&
      (grant.name == null ? true : trimspace(grant.name) != "")
    ])
    error_message = "Each grant requires a non-empty map key, grantee_principal, at least one operation, and a non-empty name when set."
  }
}

variable "is_enabled" {
  description = "Whether the KMS key is enabled."
  type        = bool
  default     = true
}

variable "key_material_base64" {
  description = "Base64-encoded key material to import into an external or replica external KMS key. The provider stores this value in Terraform state."
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = var.key_material_base64 == null || contains(["external", "replica_external"], var.key_type)
    error_message = "key_material_base64 applies only to external and replica_external key types."
  }
}

variable "key_spec" {
  description = "KMS key spec. Defaults to SYMMETRIC_DEFAULT. Replica key specs are inherited from the primary key."
  type        = string
  default     = null

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
      "ML_DSA_87",
    ], var.key_spec)
    error_message = "key_spec must be a valid AWS KMS key spec."
  }

  validation {
    condition     = var.key_spec == null || var.customer_master_key_spec == null
    error_message = "Use key_spec or customer_master_key_spec, not both."
  }

  validation {
    condition     = var.key_spec == null || !contains(["replica", "replica_external"], var.key_type)
    error_message = "key_spec cannot be set for replica keys because it is inherited from the primary key."
  }
}

variable "key_type" {
  description = "KMS key resource type to create: standard, external, replica, or replica_external."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "external", "replica", "replica_external"], var.key_type)
    error_message = "key_type must be standard, external, replica, or replica_external."
  }
}

variable "key_usage" {
  description = "Intended cryptographic use of a standard or external KMS key. Replica keys inherit this value from the primary key."
  type        = string
  default     = "ENCRYPT_DECRYPT"

  validation {
    condition     = contains(["ENCRYPT_DECRYPT", "SIGN_VERIFY", "GENERATE_VERIFY_MAC"], var.key_usage)
    error_message = "key_usage must be ENCRYPT_DECRYPT, SIGN_VERIFY, or GENERATE_VERIFY_MAC."
  }

  validation {
    condition     = !contains(["replica", "replica_external"], var.key_type) || var.key_usage == "ENCRYPT_DECRYPT"
    error_message = "key_usage is inherited for replica keys and must be left at its default."
  }
}

variable "multi_region" {
  description = "Whether a standard or external primary key is a multi-Region key. Replica keys are always multi-Region."
  type        = bool
  default     = false

  validation {
    condition     = !contains(["replica", "replica_external"], var.key_type) || !var.multi_region
    error_message = "multi_region is inherited for replica keys and must be left false."
  }
}

variable "policy" {
  description = "Optional KMS key policy JSON document. Null lets AWS KMS apply its default key policy."
  type        = string
  default     = null

  validation {
    condition     = var.policy == null || can(jsondecode(var.policy))
    error_message = "policy must be null or a valid JSON document."
  }
}

variable "primary_key_arn" {
  description = "ARN of the multi-Region primary key used by replica and replica_external key types."
  type        = string
  default     = null

  validation {
    condition     = contains(["replica", "replica_external"], var.key_type) ? var.primary_key_arn != null && trimspace(var.primary_key_arn) != "" : var.primary_key_arn == null
    error_message = "primary_key_arn is required for replica key types and must be null for primary key types."
  }
}

variable "region" {
  description = "AWS Region where the KMS resources are managed. Defaults to the provider Region."
  type        = string
  default     = null
}

variable "rotation_period_in_days" {
  description = "Custom automatic rotation period for a standard KMS key, from 90 through 2560 days."
  type        = number
  default     = null

  validation {
    condition     = var.rotation_period_in_days == null || (var.rotation_period_in_days >= 90 && var.rotation_period_in_days <= 2560)
    error_message = "rotation_period_in_days must be null or between 90 and 2560 days."
  }

  validation {
    condition     = var.rotation_period_in_days == null || (var.key_type == "standard" && var.enable_key_rotation)
    error_message = "rotation_period_in_days requires key_type = standard and enable_key_rotation = true."
  }
}

variable "tags" {
  description = "Tags to apply to the selected KMS key."
  type        = map(string)
  default     = {}
}

variable "valid_to" {
  description = "Optional RFC3339 expiration time for imported key material on an external or replica external key."
  type        = string
  default     = null

  validation {
    condition     = var.valid_to == null || contains(["external", "replica_external"], var.key_type)
    error_message = "valid_to applies only to external and replica_external key types."
  }
}

variable "xks_key_id" {
  description = "ID of the external key material used by a standard key in an external custom key store."
  type        = string
  default     = null

  validation {
    condition     = var.xks_key_id == null || (var.key_type == "standard" && var.custom_key_store_id != null)
    error_message = "xks_key_id requires key_type = standard and custom_key_store_id."
  }
}
