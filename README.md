[![GitHub release (latest by date)](https://img.shields.io/github/v/release/native-cube/terraform-aws-kms)](https://github.com/native-cube/terraform-aws-kms/releases/latest)

# terraform-aws-kms

Terraform module to configure an AWS KMS key and optional alias.

## Usage

```hcl
module "kms" {
  source = "native-cube/kms/aws"
  version = "~> 2.0"

  description             = "KMS test description"
  alias_name              = "mykey"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  key_spec                = "SYMMETRIC_DEFAULT"
  rotation_period_in_days = 365

  tags = {
    Environment = "test"
  }
}
```

Set `alias_name` or `alias_name_prefix` to create an alias. If neither is set, the module creates only the KMS key and alias outputs return `null`.

## Examples

* [KMS](https://github.com/native-cube/terraform-aws-kms/tree/main/examples/core)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_kms_alias.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_alias_name"></a> [alias\_name](#input\_alias\_name) | The display name of the alias. | `string` | `null` | no |
| <a name="input_alias_name_prefix"></a> [alias\_name\_prefix](#input\_alias\_name\_prefix) | Creates an unique alias beginning with the specified prefix. Conflicts with alias\_name. | `string` | `null` | no |
| <a name="input_bypass_policy_lockout_safety_check"></a> [bypass\_policy\_lockout\_safety\_check](#input\_bypass\_policy\_lockout\_safety\_check) | Specifies whether to disable the policy lockout check performed when creating or updating the key's policy. | `bool` | `false` | no |
| <a name="input_create_timeout"></a> [create\_timeout](#input\_create\_timeout) | Custom timeout for KMS key creation, for example 5m. Defaults to the provider timeout. | `string` | `null` | no |
| <a name="input_custom_key_store_id"></a> [custom\_key\_store\_id](#input\_custom\_key\_store\_id) | ID of the CloudHSM key store or external key store where the KMS key is created. | `string` | `null` | no |
| <a name="input_customer_master_key_spec"></a> [customer\_master\_key\_spec](#input\_customer\_master\_key\_spec) | Deprecated compatibility input for key\_spec. Prefer key\_spec for new configurations. | `string` | `null` | no |
| <a name="input_deletion_window_in_days"></a> [deletion\_window\_in\_days](#input\_deletion\_window\_in\_days) | Duration in days after which the key is deleted after destruction of the resource. | `number` | `10` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the KMS key as viewed in the AWS console. | `string` | `"Parameter Store KMS key"` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | Specifies whether key rotation is enabled. | `bool` | `true` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Specifies whether the key is enabled. | `bool` | `true` | no |
| <a name="input_key_spec"></a> [key\_spec](#input\_key\_spec) | Specifies whether the KMS key contains a symmetric key, asymmetric key pair, HMAC key, SM2 key, ML-DSA key, or Ed25519 key. Defaults to SYMMETRIC\_DEFAULT. | `string` | `null` | no |
| <a name="input_key_usage"></a> [key\_usage](#input\_key\_usage) | Intended cryptographic use of the KMS key. | `string` | `"ENCRYPT_DECRYPT"` | no |
| <a name="input_multi_region"></a> [multi\_region](#input\_multi\_region) | Indicates whether the KMS key is a multi-Region (true) or regional (false) key. | `bool` | `false` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | A valid KMS key policy JSON document. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | Region where the KMS key and alias are managed. Defaults to the provider region. | `string` | `null` | no |
| <a name="input_rotation_period_in_days"></a> [rotation\_period\_in\_days](#input\_rotation\_period\_in\_days) | Number of days between automatic key rotations. Valid values are 90 through 2560. Only used when enable\_key\_rotation is true. | `number` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Mapping of additional tags. | `map(string)` | `{}` | no |
| <a name="input_xks_key_id"></a> [xks\_key\_id](#input\_xks\_key\_id) | ID of the external key that serves as key material for an external key store KMS key. | `string` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_alias_arn"></a> [alias\_arn](#output\_alias\_arn) | KMS Key Alias ARN. |
| <a name="output_alias_name"></a> [alias\_name](#output\_alias\_name) | KMS Key Alias name. |
| <a name="output_key_arn"></a> [key\_arn](#output\_key\_arn) | KMS Key ARN. |
| <a name="output_key_id"></a> [key\_id](#output\_key\_id) | KMS Key ID. |
| <a name="output_key_spec"></a> [key\_spec](#output\_key\_spec) | KMS Key spec. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Map of tags assigned to the KMS key, including provider default tags. |
<!-- END_TF_DOCS -->

## License

See LICENSE file for full details.

## Pre-commit hooks

### Install dependencies

* [`pre-commit`](https://pre-commit.com/#install)
* [`terraform-docs`](https://github.com/segmentio/terraform-docs) required for `terraform_docs` hooks.
* [`TFLint`](https://github.com/terraform-linters/tflint) required for `terraform_tflint` hook.

#### MacOS

```bash
brew install pre-commit terraform-docs tflint

brew tap git-chglog/git-chglog
brew install git-chglog
```
