# terraform-aws-attribute-sensor
The module provisions all required infrastracture resources for the Attribute Sensor to operate. Please, refer to the [Input](#inputs) section for the configuration options.
## Registration Methods
For now, the module supports two registration methods:
### Cloud Formation
The module will create a CloudFormation stack to register the Attribute Sensor and configure the `Data Export` resource.
### Manual
The Attribute Sensor must be registered manually. Also, in that case, the `Data Export` resource will be created and managed with the module and the `external_id` value must be provided to Attribute to complete the registration process.
## Cost Allocation Tags
The module can configure the ECS and EKS cost allocation tags. To control this feature, the `configure_ecs_cost_allocation_tags` and `configure_eks_cost_allocation_tags` inputs can be adjusted. The configuration requires access to the AWS Cost Explorer API.
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.47.0, < 6.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.47.0, < 6.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_bcmdataexports_export.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/bcmdataexports_export) | resource |
| [aws_ce_cost_allocation_tag.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_cost_allocation_tag) | resource |
| [aws_ce_cost_allocation_tag.eks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ce_cost_allocation_tag) | resource |
| [aws_cloudformation_stack.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployment_id"></a> [deployment\_id](#input\_deployment\_id) | (**Required**) The Deployment ID provided by Attribute. | `string` | n/a | yes |
| <a name="input_deployment_name"></a> [deployment\_name](#input\_deployment\_name) | (**Required**) The Deployment Name provided by Attribute. | `string` | n/a | yes |
| <a name="input_external_id"></a> [external\_id](#input\_external\_id) | (**Required**) The External ID used to assume the Loader IAM Role. In case of manual registration, this value must be provided to Attribute. | `string` | n/a | yes |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | (**Required**) The Organization ID provided by Attribute. | `string` | n/a | yes |
| <a name="input_configure_ecs_cost_allocation_tags"></a> [configure\_ecs\_cost\_allocation\_tags](#input\_configure\_ecs\_cost\_allocation\_tags) | (*Optional*) Whether to configure the ECS cost allocation tags. Default is 'true'. Enabling this option requires access to the AWS Cost Explorer API. | `bool` | `false` | no |
| <a name="input_configure_eks_cost_allocation_tags"></a> [configure\_eks\_cost\_allocation\_tags](#input\_configure\_eks\_cost\_allocation\_tags) | (*Optional*) Whether to configure the EKS cost allocation tags. Default is 'true'. Enabling this option requires access to the AWS Cost Explorer API. | `bool` | `true` | no |
| <a name="input_registration_method"></a> [registration\_method](#input\_registration\_method) | (*Optional*) The registration method to use. Available options are: 'cloudformation' or 'manual'. Default is 'cloudformation'. | `string` | `"cloudformation"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cur_s3_bucket_arn"></a> [cur\_s3\_bucket\_arn](#output\_cur\_s3\_bucket\_arn) | The S3 bucket where the CUR 2.0 reports are stored. |
| <a name="output_cur_s3_bucket_policy_id"></a> [cur\_s3\_bucket\_policy\_id](#output\_cur\_s3\_bucket\_policy\_id) | The S3 bucket policy applied to the CUR 2.0 bucket. |
| <a name="output_external_id"></a> [external\_id](#output\_external\_id) | The External ID used to assume the Loader IAM Role. |
| <a name="output_loader_iam_role_arn"></a> [loader\_iam\_role\_arn](#output\_loader\_iam\_role\_arn) | The IAM role used by the loader to access the CUR 2.0 data. |
<!-- END_TF_DOCS -->