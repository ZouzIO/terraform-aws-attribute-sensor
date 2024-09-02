variable "organization_id" {
  type        = string
  description = "(**Required**) The Organization ID provided by Attribute."
}

variable "deployment_id" {
  type        = string
  description = "(**Required**) The Deployment ID provided by Attribute."
}

variable "deployment_name" {
  type        = string
  description = "(**Required**) The Deployment Name provided by Attribute."
}

variable "external_id" {
  type        = string
  sensitive   = true
  description = "(**Required**) The External ID used to assume the Loader IAM Role. In case of manual registration, this value must be provided to Attribute."
}

variable "registration_method" {
  type        = string
  description = "(*Optional*) The registration method to use. Available options are: 'cloudformation' or 'manual'. Default is 'cloudformation'."
  default     = "cloudformation"

  validation {
    condition     = contains(["cloudformation", "manual"], var.registration_method)
    error_message = "Invalid registration method. Must be 'cloudformation' or 'manual'."
  }
}
variable "configure_eks_cost_allocation_tags" {
  type        = bool
  description = "(*Optional*) Whether to configure the EKS cost allocation tags. Default is 'true'. Enabling this option requires access to the AWS Cost Explorer API."
  default     = true
}

variable "configure_ecs_cost_allocation_tags" {
  type        = bool
  description = "(*Optional*) Whether to configure the ECS cost allocation tags. Default is 'true'. Enabling this option requires access to the AWS Cost Explorer API."
  default     = false
}
