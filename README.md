# terraform-aws-attribute-sensor
The module provisions all required infrastracture resources for the Attribute Sensor to operate. Please, refer to the [Input](#inputs) section for the configuration options.
## Account types
The module supports two account types: `management` and `sub`. You can use a single `manamgement` account and multiple `sub` accounts in the same organization.
### Management
**Management account resources must be created in the `us-east-1` region.**

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
For now, the module supports three registration methods:
### Cloud Formation
The module will create a CloudFormation stack to register the Attribute Sensor automatically.
### HTTP
The module invokes an HTTP request in order to register the Attribute Sensor automatically. In this case, the `token` value must be provided to authenticate the request.
### Manual
The Attribute Sensor must be registered manually. Also, in that case, the `external_id` value must be provided to Attribute to complete the registration process.
## Cost Allocation Tags
The module can configure the ECS and EKS cost allocation tags. To control this feature, the `configure_ecs_cost_allocation_tags` and `configure_eks_cost_allocation_tags` inputs can be adjusted. The configuration requires access to the AWS Cost Explorer API.

## Upgrading
### v1 -> v2
* The `ZouzCurExport` Billing Data Export must be deleted manually after the upgrade as it's managed by the module now.

## Permissions required
This section describes the permissions required by the principal that **executes Terraform** (`terraform apply` / `terraform destroy`). These are not the permissions of the Loader IAM Role — that role and its policies are created by the module itself.

A few non-obvious requirements to be aware of:
- **The CloudFormation registration publishes to an SNS topic.** With `registration_method = "cloudformation"` the stack contains a custom resource whose `ServiceToken` is an SNS topic in the Attribute account. CloudFormation delivers the registration message (on both stack create **and** delete) using the credentials of the principal that runs the stack operation, so the principal needs `sns:Publish` on the Attribute topic. Because the topic is encrypted at rest, the principal also needs `kms:GenerateDataKey` and `kms:Decrypt` on the topic's KMS key — scoped with the `kms:ViaService` condition below, since the key lives in the Attribute account.
- **BCM Data Exports needs a CUR permission too.** Creating a CUR 2.0 export requires `cur:PutReportDefinition` in addition to the `bcm-data-exports:*` actions. Note the IAM action prefix is `bcm-data-exports:`, not `bcm:`.
- **The `aws_s3_bucket` resource reads more than the module manages.** During refresh the AWS provider reads every bucket sub-configuration (versioning, logging, CORS, encryption, lifecycle, replication, etc.), so the policy must include the corresponding `s3:Get*` actions even though the module never configures them.
- **Destroy needs extra IAM reads.** Deleting the Loader IAM Role requires `iam:ListInstanceProfilesForRole` in addition to the `iam:Delete*` actions.
- **Cost allocation tags are management-only and enabled by default.** `ce:ListCostAllocationTags` / `ce:UpdateCostAllocationTagsStatus` can only be called from the management (payer) account. Set `configure_ecs_cost_allocation_tags = false` and `configure_eks_cost_allocation_tags = false` to drop this requirement.
- The module also calls `sts:GetCallerIdentity`, which requires no explicit permissions.

Replace `<ACCOUNT_ID>` in the policies below with the ID of the AWS account the module is applied to. The wildcards in the resource ARNs account for an optional `name_prefix`. If you use the `http` or `manual` registration method, the `Registration*` statements can be removed.

### Management account
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "CurBucketManager",
      "Effect": "Allow",
      "Action": [
        "s3:CreateBucket",
        "s3:DeleteBucket",
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:GetBucketTagging",
        "s3:PutBucketTagging",
        "s3:GetBucketAcl",
        "s3:PutBucketAcl",
        "s3:GetBucketOwnershipControls",
        "s3:PutBucketOwnershipControls",
        "s3:GetBucketPolicy",
        "s3:PutBucketPolicy",
        "s3:DeleteBucketPolicy",
        "s3:GetBucketVersioning",
        "s3:GetBucketRequestPayment",
        "s3:GetBucketLogging",
        "s3:GetBucketWebsite",
        "s3:GetBucketCORS",
        "s3:GetBucketObjectLockConfiguration",
        "s3:GetLifecycleConfiguration",
        "s3:GetReplicationConfiguration",
        "s3:GetAccelerateConfiguration",
        "s3:GetEncryptionConfiguration"
      ],
      "Resource": "arn:aws:s3:::*attribute-cur-us-east-1-<ACCOUNT_ID>"
    },
    {
      "Sid": "CurExportManager",
      "Effect": "Allow",
      "Action": [
        "bcm-data-exports:CreateExport",
        "bcm-data-exports:GetExport",
        "bcm-data-exports:UpdateExport",
        "bcm-data-exports:DeleteExport",
        "bcm-data-exports:ListTagsForResource",
        "bcm-data-exports:TagResource",
        "bcm-data-exports:UntagResource"
      ],
      "Resource": [
        "arn:aws:bcm-data-exports:us-east-1:<ACCOUNT_ID>:export/*",
        "arn:aws:bcm-data-exports:us-east-1:<ACCOUNT_ID>:table/COST_AND_USAGE_REPORT"
      ]
    },
    {
      "Sid": "CurReportDefinitionPlacer",
      "Effect": "Allow",
      "Action": "cur:PutReportDefinition",
      "Resource": "*"
    },
    {
      "Sid": "CostAllocationTagsConfigurer",
      "Effect": "Allow",
      "Action": [
        "ce:ListCostAllocationTags",
        "ce:UpdateCostAllocationTagsStatus"
      ],
      "Resource": "*"
    },
    {
      "Sid": "LoaderRoleManager",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:GetRole",
        "iam:UpdateRole",
        "iam:UpdateAssumeRolePolicy",
        "iam:DeleteRole",
        "iam:TagRole",
        "iam:UntagRole",
        "iam:PutRolePolicy",
        "iam:GetRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "iam:ListInstanceProfilesForRole"
      ],
      "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/*AttributeLoaderV-*"
    },
    {
      "Sid": "RegistrationStackManager",
      "Effect": "Allow",
      "Action": [
        "cloudformation:CreateStack",
        "cloudformation:DescribeStacks",
        "cloudformation:GetTemplate",
        "cloudformation:GetStackPolicy",
        "cloudformation:UpdateStack",
        "cloudformation:DeleteStack"
      ],
      "Resource": "arn:aws:cloudformation:*:<ACCOUNT_ID>:stack/*AttributeRegistration/*"
    },
    {
      "Sid": "RegistrationMessagePublisher",
      "Effect": "Allow",
      "Action": "sns:Publish",
      "Resource": "arn:aws:sns:us-east-1:405726414835:ZouzDeploymentRegistration"
    },
    {
      "Sid": "RegistrationTopicKeyUser",
      "Effect": "Allow",
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:ViaService": "sns.us-east-1.amazonaws.com"
        }
      }
    }
  ]
}
```
### Sub account
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "LoaderRoleManager",
      "Effect": "Allow",
      "Action": [
        "iam:CreateRole",
        "iam:GetRole",
        "iam:UpdateRole",
        "iam:UpdateAssumeRolePolicy",
        "iam:DeleteRole",
        "iam:TagRole",
        "iam:UntagRole",
        "iam:PutRolePolicy",
        "iam:GetRolePolicy",
        "iam:DeleteRolePolicy",
        "iam:ListRolePolicies",
        "iam:ListAttachedRolePolicies",
        "iam:ListInstanceProfilesForRole"
      ],
      "Resource": "arn:aws:iam::<ACCOUNT_ID>:role/*AttributeLoaderV-*"
    },
    {
      "Sid": "RegistrationStackManager",
      "Effect": "Allow",
      "Action": [
        "cloudformation:CreateStack",
        "cloudformation:DescribeStacks",
        "cloudformation:GetTemplate",
        "cloudformation:GetStackPolicy",
        "cloudformation:UpdateStack",
        "cloudformation:DeleteStack"
      ],
      "Resource": "arn:aws:cloudformation:*:<ACCOUNT_ID>:stack/*AttributeRegistration/*"
    },
    {
      "Sid": "RegistrationMessagePublisher",
      "Effect": "Allow",
      "Action": "sns:Publish",
      "Resource": "arn:aws:sns:us-east-1:405726414835:ZouzDeploymentRegistration"
    },
    {
      "Sid": "RegistrationTopicKeyUser",
      "Effect": "Allow",
      "Action": [
        "kms:GenerateDataKey",
        "kms:Decrypt"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "kms:ViaService": "sns.us-east-1.amazonaws.com"
        }
      }
    }
  ]
}
```
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
## Additional policies
In case the default permissions of the Loader IAM Role are not sufficient, an additional inline policy can be attached to the role using the `additional_policy` input. The policy must be provided in a JSON format, for example, using `jsonencode(...)` or `data.aws_iam_policy_document`. If the `additional_policy` input is left empty, no additional policy will be attached to the role.

```hcl
module "attribute_sensor" {
  # Some fields omitted for brevity

  additional_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ExtraBucketReader"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
        ]
        Resource = [
          "arn:aws:s3:::my-extra-bucket",
          "arn:aws:s3:::my-extra-bucket/*",
        ]
      },
    ]
  })
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.48.0, < 7.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.48.0, < 7.0.0 |
| <a name="provider_http"></a> [http](#provider\_http) | n/a |

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
| [aws_iam_role_policy.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_acl) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [http_http.attribute_registration](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_name"></a> [account\_name](#input\_account\_name) | (**Required**) The AWS Account name. | `string` | n/a | yes |
| <a name="input_account_type"></a> [account\_type](#input\_account\_type) | (**Required**) The AWS Account type. Available options are: 'management' or 'sub'. | `string` | n/a | yes |
| <a name="input_external_id"></a> [external\_id](#input\_external\_id) | (**Required**) The External ID used to assume the Loader IAM Role. In case of manual registration, this value must be provided to Attribute. | `string` | n/a | yes |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | (**Required**) The Organization ID provided by Attribute. | `string` | n/a | yes |
| <a name="input_additional_policy"></a> [additional\_policy](#input\_additional\_policy) | (*Optional*) A JSON IAM policy document attached as an additional inline policy on the Loader IAM Role. Build it with `jsonencode(...)` or `data.aws_iam_policy_document`. Leave empty to skip. | `string` | `""` | no |
| <a name="input_cloudtrail_enabled"></a> [cloudtrail\_enabled](#input\_cloudtrail\_enabled) | (*Optional*) Whether to enable CloudTrail for the Loader IAM Role. Default is 'false'. | `bool` | `false` | no |
| <a name="input_configure_ecs_cost_allocation_tags"></a> [configure\_ecs\_cost\_allocation\_tags](#input\_configure\_ecs\_cost\_allocation\_tags) | (*Optional*) Whether to configure the ECS cost allocation tags. Default is 'true'. Enabling this option requires access to the AWS Cost Explorer API. | `bool` | `true` | no |
| <a name="input_configure_eks_cost_allocation_tags"></a> [configure\_eks\_cost\_allocation\_tags](#input\_configure\_eks\_cost\_allocation\_tags) | (*Optional*) Whether to configure the EKS cost allocation tags. Default is 'true'. Enabling this option requires access to the AWS Cost Explorer API. | `bool` | `true` | no |
| <a name="input_general_tags"></a> [general\_tags](#input\_general\_tags) | (*Optional*) The tags to apply to the resources created by the module. | `map(string)` | `{}` | no |
| <a name="input_logs_export_buckets"></a> [logs\_export\_buckets](#input\_logs\_export\_buckets) | (*Optional*) The list of S3 buckets to grant access to the Loader IAM Role for ingesting logs. | `list(string)` | `[]` | no |
| <a name="input_managed_by_reseller"></a> [managed\_by\_reseller](#input\_managed\_by\_reseller) | (*Optional*) Whether the AWS Account is managed by a reseller. Enabling this option disables the 'Split Cost Allocation' feature. Default is 'false'. | `bool` | `false` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (*Optional*) The prefix to use for naming resources created by the module. | `string` | `""` | no |
| <a name="input_registration_method"></a> [registration\_method](#input\_registration\_method) | (*Optional*) The registration method to use. Available options are: 'cloudformation' or 'manual'. Default is 'cloudformation'. | `string` | `"cloudformation"` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | (*Optional*) Additional tags to apply to specific resources created by the module. | `map(map(string))` | `{}` | no |
| <a name="input_token"></a> [token](#input\_token) | (**Required for HTTP registration method**) The registration token provided by Attribute. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cur_export_name"></a> [cur\_export\_name](#output\_cur\_export\_name) | The name of the CUR 2.0 report definition. |
| <a name="output_cur_prefix"></a> [cur\_prefix](#output\_cur\_prefix) | The prefix within the S3 bucket where the CUR 2.0 reports are stored. |
| <a name="output_cur_s3_bucket_arn"></a> [cur\_s3\_bucket\_arn](#output\_cur\_s3\_bucket\_arn) | The S3 bucket where the CUR 2.0 reports are stored. |
| <a name="output_cur_s3_bucket_policy_id"></a> [cur\_s3\_bucket\_policy\_id](#output\_cur\_s3\_bucket\_policy\_id) | The S3 bucket policy applied to the CUR 2.0 bucket. |
| <a name="output_external_id"></a> [external\_id](#output\_external\_id) | The External ID used to assume the Loader IAM Role. |
| <a name="output_loader_iam_role_arn"></a> [loader\_iam\_role\_arn](#output\_loader\_iam\_role\_arn) | The IAM role used by the loader to access the CUR 2.0 data. |
<!-- END_TF_DOCS -->