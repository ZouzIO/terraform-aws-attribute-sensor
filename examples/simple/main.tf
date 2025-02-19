resource "random_uuid" "external_id" {}

module "attribute-sensor" {
  source  = "ZouzIO/attribute-sensor/aws"
  version = "~> 2.0"

  account_name    = "my-org-mgmt"
  account_type    = "management"
  organization_id = var.organization_id
  external_id     = random_uuid.external_id.id
}
