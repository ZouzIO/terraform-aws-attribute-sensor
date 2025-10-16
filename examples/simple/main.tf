resource "random_uuid" "external_id" {}

module "attribute_sensor" {
  source = "../../"

  account_name    = var.account_name
  name_prefix     = var.name_prefix
  account_type    = var.account_type
  organization_id = var.organization_id
  external_id     = random_uuid.external_id.id

  configure_ecs_cost_allocation_tags = false
  configure_eks_cost_allocation_tags = false

  general_tags        = var.general_tags
  registration_method = var.registration_method
  token               = var.token
}
