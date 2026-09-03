# Terraform AWS KMS Module

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/native-cube/terraform-aws-kms)](https://github.com/native-cube/terraform-aws-kms/releases/latest)

Reusable Terraform module for one AWS KMS key per module call. It follows the sibling EKS, ElastiCache, and S3 module conventions: a selected singleton primary resource named `main`, flat documented inputs, stable maps for repeatable resources, resources split by concern, composition outputs, native tests, runnable examples, and generated documentation.

## Key types

| `key_type` | Terraform resource | Purpose |
| --- | --- | --- |
| `standard` | `aws_kms_key.main` | AWS-generated key material; this is the default |
| `external` | `aws_kms_external_key.main` | Imported key material for a primary key |
| `replica` | `aws_kms_replica_key.main` | AWS-generated-material replica of a multi-Region primary key |
| `replica_external` | `aws_kms_replica_external_key.main` | Imported-material replica of a multi-Region external primary key |

Use a separate module call for each independent key. For replicas, set `primary_key_arn` and use `region` to select the destination Region without requiring a provider alias on AWS provider 6.x.

## Usage

```hcl
module "kms" {
  source  = "native-cube/kms/aws"
  version = "~> 2.1"

  description             = "Orders data encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  key_spec                = "SYMMETRIC_DEFAULT"
  rotation_period_in_days = 365

  aliases = {
    application = {
      name = "orders/data"
    }
  }

  grants = {
    orders = {
      grantee_principal = aws_iam_role.orders.arn
      operations        = ["Decrypt", "GenerateDataKey"]
      constraints = [{
        encryption_context_equals = {
          Service = "orders"
        }
      }]
    }
  }

  tags = {
    Environment = "production"
    Service     = "orders"
  }
}
```

`alias_name` and `alias_name_prefix` remain available for compatibility and retain the existing `aws_kms_alias.main[0]` address. Prefer the `aliases` map for new configurations so multiple aliases have stable keys.

## Policies, grants, and key material

- Set `policy` to a valid KMS key policy JSON document. When it is null, AWS KMS applies its default key policy. Do not manage the same policy with `aws_kms_key_policy` as well.
- `bypass_policy_lockout_safety_check = true` can make a key unmanageable. Leave it disabled unless the supplied policy has been independently verified.
- External key material is sensitive, but the AWS provider stores `key_material_base64` in Terraform state. Use an encrypted remote backend with tightly restricted access and inject the value through a secure workflow.
- Grants are keyed by stable map keys and support every AWS provider grant argument, including encryption-context constraints, grant creation tokens, retirement settings, and all KMS operations accepted by the provider.
- Automatic rotation settings apply to `standard` keys. Replica keys inherit their key spec, key usage, and rotation state from the primary key.
- Treat `key_type` and `create` as lifecycle controls: changing the key type or disabling creation destroys the currently selected key after its deletion window. Use policy-as-code or a caller wrapper with `prevent_destroy` when accidental key deletion must be blocked.

## Provider argument coverage

Every configurable argument and nested block in HashiCorp AWS provider 6.62.0 is wired for:

- `aws_kms_key`
- `aws_kms_external_key`
- `aws_kms_replica_key`
- `aws_kms_replica_external_key`
- `aws_kms_alias`
- `aws_kms_grant`

`make schema-check` compares the initialized provider schema with all six resource definitions and fails if a configurable argument or nested-block field is missing.

The module accepts an existing `custom_key_store_id` and optional `xks_key_id`, but intentionally does not provision `aws_kms_custom_key_store`; CloudHSM and external key-store connectivity and credentials have a separate lifecycle. It also does not create `aws_kms_ciphertext` resources because encrypting application plaintext in Terraform can expose sensitive data through configuration or state.

## Compatibility

Module version 2.1.0 requires Terraform 1.9 or newer and HashiCorp AWS provider 6.62 or newer. Root configurations should set their own compatible upper bound and commit a dependency lock file. Existing standard keys are migrated from `aws_kms_key.main` to `aws_kms_key.main[0]` by the included `moved` block. The default remains a standard symmetric key, and the legacy single-alias inputs and outputs remain supported.

## Examples

- [`examples/core`](examples/core) - standard symmetric key with rotation and multiple aliases.
- [`examples/external`](examples/external) - primary key with securely supplied imported key material.
- [`examples/multi-region`](examples/multi-region) - primary and replica keys in two Regions through separate module calls.

## Development

Run `make check` to verify formatting, generated documentation, initialization, validation, native Terraform tests, provider argument coverage, and every example. Run `make docs` after changing inputs, outputs, resources, or version constraints.

## Module Documentation

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.62.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.62.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_kms_alias.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_alias.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_external_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_external_key) | resource |
| [aws_kms_grant.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_grant) | resource |
| [aws_kms_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_replica_external_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_external_key) | resource |
| [aws_kms_replica_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_replica_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alias_name"></a> [alias\_name](#input\_alias\_name) | Legacy exact alias name to create without the alias/ prefix. Prefer aliases for new configurations. | `string` | `null` | no |
| <a name="input_alias_name_prefix"></a> [alias\_name\_prefix](#input\_alias\_name\_prefix) | Legacy alias name prefix to create without the alias/ prefix. Prefer aliases for new configurations. | `string` | `null` | no |
| <a name="input_aliases"></a> [aliases](#input\_aliases) | Additional KMS aliases keyed by a stable Terraform key. Set exactly one of name or name\_prefix and omit the alias/ prefix. | <pre>map(object({<br/>    name        = optional(string)<br/>    name_prefix = optional(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_bypass_policy_lockout_safety_check"></a> [bypass\_policy\_lockout\_safety\_check](#input\_bypass\_policy\_lockout\_safety\_check) | Whether to bypass the policy lockout safety check. Enabling this can make the KMS key unmanageable. | `bool` | `false` | no |
| <a name="input_create"></a> [create](#input\_create) | Whether to create the selected KMS key, aliases, and grants. | `bool` | `true` | no |
| <a name="input_create_timeout"></a> [create\_timeout](#input\_create\_timeout) | Optional custom creation timeout for a standard KMS key, for example 5m. | `string` | `null` | no |
| <a name="input_custom_key_store_id"></a> [custom\_key\_store\_id](#input\_custom\_key\_store\_id) | ID of an existing CloudHSM or external custom key store for a standard key. | `string` | `null` | no |
| <a name="input_customer_master_key_spec"></a> [customer\_master\_key\_spec](#input\_customer\_master\_key\_spec) | Deprecated compatibility input for key\_spec. Prefer key\_spec for new configurations. | `string` | `null` | no |
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | Waiting period in days before AWS KMS permanently deletes the key. | `number` | `10` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the KMS key. | `string` | `"Parameter Store KMS key"` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | Whether automatic rotation is enabled for a standard KMS key. | `bool` | `true` | no |
| <a name="input_grants"></a> [grants](#input\_grants) | KMS grants to create for the selected key, keyed by a stable Terraform key. | <pre>map(object({<br/>    grantee_principal     = string<br/>    operations            = set(string)<br/>    name                  = optional(string)<br/>    grant_creation_tokens = optional(set(string), [])<br/>    retire_on_delete      = optional(bool)<br/>    retiring_principal    = optional(string)<br/>    constraints = optional(list(object({<br/>      encryption_context_equals = optional(map(string))<br/>      encryption_context_subset = optional(map(string))<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Whether the KMS key is enabled. | `bool` | `true` | no |
| <a name="input_key_material_base64"></a> [key\_material\_base64](#input\_key\_material\_base64) | Base64-encoded key material to import into an external or replica external KMS key. The provider stores this value in Terraform state. | `string` | `null` | no |
| <a name="input_key_spec"></a> [key\_spec](#input\_key\_spec) | KMS key spec. Defaults to SYMMETRIC\_DEFAULT. Replica key specs are inherited from the primary key. | `string` | `null` | no |
| <a name="input_key_type"></a> [key\_type](#input\_key\_type) | KMS key resource type to create: standard, external, replica, or replica\_external. | `string` | `"standard"` | no |
| <a name="input_key_usage"></a> [key\_usage](#input\_key\_usage) | Intended cryptographic use of a standard or external KMS key. Replica keys inherit this value from the primary key. | `string` | `"ENCRYPT_DECRYPT"` | no |
| <a name="input_multi_region"></a> [multi\_region](#input\_multi\_region) | Whether a standard or external primary key is a multi-Region key. Replica keys are always multi-Region. | `bool` | `false` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | Optional KMS key policy JSON document. Null lets AWS KMS apply its default key policy. | `string` | `null` | no |
| <a name="input_primary_key_arn"></a> [primary\_key\_arn](#input\_primary\_key\_arn) | ARN of the multi-Region primary key used by replica and replica\_external key types. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS Region where the KMS resources are managed. Defaults to the provider Region. | `string` | `null` | no |
| <a name="input_rotation_period_in_days"></a> [rotation\_period\_in\_days](#input\_rotation\_period\_in\_days) | Custom automatic rotation period for a standard KMS key, from 90 through 2560 days. | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the selected KMS key. | `map(string)` | `{}` | no |
| <a name="input_valid_to"></a> [valid\_to](#input\_valid\_to) | Optional RFC3339 expiration time for imported key material on an external or replica external key. | `string` | `null` | no |
| <a name="input_xks_key_id"></a> [xks\_key\_id](#input\_xks\_key\_id) | ID of the external key material used by a standard key in an external custom key store. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alias_arn"></a> [alias\_arn](#output\_alias\_arn) | ARN of the legacy alias, or null when alias\_name and alias\_name\_prefix are omitted. |
| <a name="output_alias_name"></a> [alias\_name](#output\_alias\_name) | Name of the legacy alias, or null when alias\_name and alias\_name\_prefix are omitted. |
| <a name="output_alias_target_key_arn"></a> [alias\_target\_key\_arn](#output\_alias\_target\_key\_arn) | Target key ARN of the legacy alias, or null when the legacy alias is not created. |
| <a name="output_aliases"></a> [aliases](#output\_aliases) | Additional aliases created by the module, keyed by the aliases input map key. |
| <a name="output_external_key_expiration_model"></a> [external\_key\_expiration\_model](#output\_external\_key\_expiration\_model) | Expiration model of imported key material, or null for non-external keys. |
| <a name="output_external_key_state"></a> [external\_key\_state](#output\_external\_key\_state) | State of the external KMS key, or null for non-external keys. |
| <a name="output_grants"></a> [grants](#output\_grants) | KMS grants created by the module, keyed by the grants input map key. |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | ARN of the selected KMS key, or null when creation is disabled. |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | ID of the selected KMS key, or null when creation is disabled. |
| <a name="output_key_policy"></a> [key\_policy](#output\_key\_policy) | Policy reported for the selected KMS key, or null when creation is disabled. |
| <a name="output_key_region"></a> [key\_region](#output\_key\_region) | Region where the selected KMS key is managed, or null when creation is disabled. |
| <a name="output_key_spec"></a> [key\_spec](#output\_key\_spec) | Key spec of the selected KMS key, including the inherited spec for a replica. |
| <a name="output_key_type"></a> [key\_type](#output\_key\_type) | Selected KMS key resource type, or null when creation is disabled. |
| <a name="output_key_usage"></a> [key\_usage](#output\_key\_usage) | Cryptographic usage of the selected KMS key. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Tags assigned to the selected KMS key, including provider default tags. |
<!-- END_TF_DOCS -->

## License

See [LICENSE](LICENSE) for details.
