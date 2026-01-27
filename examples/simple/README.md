# Attribute Sensor Simple Example
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_attribute_sensor"></a> [attribute\_sensor](#module\_attribute\_sensor) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [random_uuid.external_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_type"></a> [account\_type](#input\_account\_type) | (Required) The AWS Account type. Available options are: 'management' or 'sub'. | `string` | n/a | yes |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | (Required) The Organization ID provided by Attribute | `string` | n/a | yes |
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | (Required) The AWS Account name | `string` | `""` | no |
| <a name="input_general_tags"></a> [general\_tags](#input\_general\_tags) | (*Optional*) A map of tags to assign to resources created by the module. | `map(string)` | `{}` | no |
| <a name="input_managed_by_reseller"></a> [managed\_by\_reseller](#input\_managed\_by\_reseller) | (Optional) Whether the account is managed by a reseller. Default is false. | `bool` | `false` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (*Optional*) The prefix to use for naming resources created by the module. | `string` | `""` | no |
| <a name="input_registration_method"></a> [registration\_method](#input\_registration\_method) | (*Optional*) The registration method to use. Available options are: 'cloudformation' or 'manual'. Default is 'cloudformation'. | `string` | `"cloudformation"` | no |
| <a name="input_token"></a> [token](#input\_token) | (**Required for HTTP registration method**) The registration token provided by Attribute. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cur_export_name"></a> [cur\_export\_name](#output\_cur\_export\_name) | The name of the CUR 2.0 report definition. |
| <a name="output_cur_prefix"></a> [cur\_prefix](#output\_cur\_prefix) | The prefix within the S3 bucket where the CUR 2.0 reports are stored. |
| <a name="output_cur_s3_bucket_arn"></a> [cur\_s3\_bucket\_arn](#output\_cur\_s3\_bucket\_arn) | The S3 bucket where the CUR 2.0 reports are stored. |
| <a name="output_external_id"></a> [external\_id](#output\_external\_id) | The External ID used to assume the Loader IAM Role. |
| <a name="output_loader_iam_role_arn"></a> [loader\_iam\_role\_arn](#output\_loader\_iam\_role\_arn) | The IAM role used by the loader to access the CUR 2.0 data. |
<!-- END_TF_DOCS -->