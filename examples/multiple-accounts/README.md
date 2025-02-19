# Attribute Sensor Simple Example
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_random"></a> [random](#provider\_random) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_attribute-sensor-mgmt"></a> [attribute-sensor-mgmt](#module\_attribute-sensor-mgmt) | ZouzIO/attribute-sensor/aws | ~> 2.0 |
| <a name="module_attribute-sensor-sub-1"></a> [attribute-sensor-sub-1](#module\_attribute-sensor-sub-1) | ZouzIO/attribute-sensor/aws | ~> 2.0 |
| <a name="module_attribute-sub-2"></a> [attribute-sub-2](#module\_attribute-sub-2) | ZouzIO/attribute-sensor/aws | ~> 2.0 |
| <a name="module_attribute-sub-3"></a> [attribute-sub-3](#module\_attribute-sub-3) | ZouzIO/attribute-sensor/aws | ~> 2.0 |

## Resources

| Name | Type |
|------|------|
| [random_uuid.external_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/uuid) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_organization_id"></a> [organization\_id](#input\_organization\_id) | (Required) The Organization ID provided by Attribute | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->