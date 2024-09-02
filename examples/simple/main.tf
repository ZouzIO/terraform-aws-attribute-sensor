resource "random_uuid" "external_id" {}

module "attribute-sensor" {
  # TODO: Registry URL
  source = "../../modules/terraform-aws-attribute-sensor"

  organization_id = var.organization_id
  deployment_id   = var.deployment_id
  deployment_name = var.deployment_name
  external_id     = random_uuid.external_id.id
}
