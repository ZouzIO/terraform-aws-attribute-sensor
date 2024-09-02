resource "random_uuid" "external_id" {}

module "attribute-sensor" {
  source  = "ZouzIO/attribute-sensor/aws"
  version = "~> 1"

  organization_id = var.organization_id
  deployment_id   = var.deployment_id
  deployment_name = var.deployment_name
  external_id     = random_uuid.external_id.id
}
