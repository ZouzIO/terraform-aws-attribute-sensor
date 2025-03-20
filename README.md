# terraform-aws-attribute-sensor
The module provisions all required infrastracture resources for the Attribute Sensor to operate. Please, refer to the [Input](#inputs) section for the configuration options.
## Account types
The module supports two account types: `management` and `sub`. You can use a single `manamgement` account and multiple `sub` accounts in the same organization.
### Management
* Management account must be created in the `us-east-1` region.*

The following resources are created in the management account:
- S3 bucket and ACLs for the CUR 2.0 reports
- IAM role for the Loader
- Billing Data Export resource
- CloudFormation stack for the Attribute Sensor registration ( optional )
- ECS and EKS cost allocation tags ( optional )
### Sub
The following resources are created in the sub account:
- IAM role for the Loader
- CloudFormation stack for the Attribute Sensor registration ( optional )

## Registration Methods
For now, the module supports two registration methods:
### Cloud Formation
The module will create a CloudFormation stack to register the Attribute Sensor automatically.
### Manual
The Attribute Sensor must be registered manually. Also, in that case, the `external_id` value must be provided to Attribute to complete the registration process.
## Cost Allocation Tags
The module can configure the ECS and EKS cost allocation tags. To control this feature, the `configure_ecs_cost_allocation_tags` and `configure_eks_cost_allocation_tags` inputs can be adjusted. The configuration requires access to the AWS Cost Explorer API.

## Upgrading
### v1 -> v2
* The `ZouzCurExport` Billing Data Export must be deleted manually after the upgrade as it's managed by the module now.

## Permissions required
In order to use the module, the following permissions are required:
| **Service**                                              | **Permissions**                                                                                                           |
| -------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- |
| **BCM (bcmdataexports_export)**                          | `bcm:CreateDataExport`, `bcm:DeleteDataExport`, `bcm:DescribeDataExports`                                                 |
| **Cost Explorer (ce_cost_allocation_tag)**               | `ce:CreateCostAllocationTag`, `ce:DescribeCostAllocationTags`, `ce:UpdateCostAllocationTag`                               |
| **CloudFormation (cloudformation_stack)**                | `cloudformation:CreateStack`, `cloudformation:DescribeStacks`, `cloudformation:UpdateStack`, `cloudformation:DeleteStack` |
| **IAM (iam_role)**                                       | `iam:CreateRole`, `iam:PutRolePolicy`, `iam:DeleteRole`, `iam:DeleteRolePolicy`, `iam:ListRoles`                          |
| **S3 Bucket (s3_bucket)**                                | `s3:CreateBucket`, `s3:DeleteBucket`, `s3:ListBucket`, `s3:GetBucketLocation`                                             |
| **S3 Bucket ACL (s3_bucket_acl)**                        | `s3:PutBucketAcl`, `s3:GetBucketAcl`                                                                                      |
| **S3 Ownership Controls (s3_bucket_ownership_controls)** | `s3:PutBucketOwnershipControls`, `s3:GetBucketOwnershipControls`                                                          |
| **S3 Bucket Policy (s3_bucket_policy)**                  | `s3:PutBucketPolicy`, `s3:GetBucketPolicy`, `s3:DeleteBucketPolicy`                                                       |
| **STS (caller_identity)**                                | `sts:GetCallerIdentity`                                                                                                   |
## Adding tags to created resources
Two inputs can be used to add tags to the created resources:
- `general_tags` - a map of tags to be added to all resources provisioned by the module
- `resource_tags` - a map of tags to be added to specific resources
`general_tags` will be merged with `resource_tags` for a specific resource, i.e.:
```hcl
module "attribute-sensor" {
  # Some fields omitted for brevity

  general_tags = {
    "managed_by" = "Terraform"
    "module"     = "attribute-sensor"
  }

  resource_tags = {
    "s3_bucket" = {
      "used_by" = "attribute-sensor"
    }
  }
}
```
will result in the following tags for the S3 bucket:
```hcl
{
  "managed_by" = "Terraform"
  "module"     = "attribute-sensor"
  "used_by"    = "attribute-sensor"
}
```
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
| [aws_cloudformation_stack.registration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudformation_stack) | resource |
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
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | (**Required**) The AWS Account name. | `string` | n/a | yes |
| <a name="input_account_type"></a> [account\_type](#input\_account\_type) | (**Required**) The AWS Account type. Available options are: 'management' or 'sub'. | `string` | n/a | yes |
| <a name="input_external_id"></a> [external\_id](#input\_external\_id) | (**Required**) The External ID used to assume the Loader IAM Role. In case of manual registration, this value must be provided to Attribute. | `string` | n/a | yes |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | (**Required**) The Organization ID provided by Attribute. | `string` | n/a | yes |
| <a name="input_configure_ecs_cost_allocation_tags"></a> [configure\_ecs\_cost\_allocation\_tags](#input\_configure\_ecs\_cost\_allocation\_tags) | (*Optional*) Whether to configure the ECS cost allocation tags. Default is 'true'. Enabling this option requires access to the AWS Cost Explorer API. | `bool` | `false` | no |
| <a name="input_configure_eks_cost_allocation_tags"></a> [configure\_eks\_cost\_allocation\_tags](#input\_configure\_eks\_cost\_allocation\_tags) | (*Optional*) Whether to configure the EKS cost allocation tags. Default is 'true'. Enabling this option requires access to the AWS Cost Explorer API. | `bool` | `true` | no |
| <a name="input_general_tags"></a> [general\_tags](#input\_general\_tags) | (*Optional*) The tags to apply to the resources created by the module. | `map(string)` | `{}` | no |
| <a name="input_logs_export_buckets"></a> [logs\_export\_buckets](#input\_logs\_export\_buckets) | (*Optional*) The list of S3 buckets to grant access to the Loader IAM Role for ingesting logs. | `list(string)` | `[]` | no |
| <a name="input_registration_method"></a> [registration\_method](#input\_registration\_method) | (*Optional*) The registration method to use. Available options are: 'cloudformation' or 'manual'. Default is 'cloudformation'. | `string` | `"cloudformation"` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | (*Optional*) Additional tags to apply to specific resources created by the module. | `map(map(string))` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cur_s3_bucket_arn"></a> [cur\_s3\_bucket\_arn](#output\_cur\_s3\_bucket\_arn) | The S3 bucket where the CUR 2.0 reports are stored. |
| <a name="output_cur_s3_bucket_policy_id"></a> [cur\_s3\_bucket\_policy\_id](#output\_cur\_s3\_bucket\_policy\_id) | The S3 bucket policy applied to the CUR 2.0 bucket. |
| <a name="output_external_id"></a> [external\_id](#output\_external\_id) | The External ID used to assume the Loader IAM Role. |
| <a name="output_loader_iam_role_arn"></a> [loader\_iam\_role\_arn](#output\_loader\_iam\_role\_arn) | The IAM role used by the loader to access the CUR 2.0 data. |
<!-- END_TF_DOCS -->