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
| <a name="module_attribute-sensor"></a> [attribute-sensor](#module\_attribute-sensor) | ZouzIO/attribute-sensor/aws | ~> 1 |

## Resources

| Name | Type |
|------|------|
| [random_uuid.external_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployment_id"></a> [deployment\_id](#input\_deployment\_id) | (Required) The Deployment ID provided by Attribute | `string` | n/a | yes |
| <a name="input_deployment_name"></a> [deployment\_name](#input\_deployment\_name) | (Required) The Deployment Name provided by Attribute | `string` | n/a | yes |
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | (Required) The Organization ID provided by Attribute | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->