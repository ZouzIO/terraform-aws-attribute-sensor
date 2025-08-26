variable "organization_id" {
  type        = string
  description = "(**Required**) The Organization ID provided by Attribute."
}

variable "account_name" {
  type        = string
  description = "(**Required**) The AWS Account name."
}

variable "account_type" {
  type        = string
  description = "(**Required**) The AWS Account type. Available options are: 'management' or 'sub'."

  validation {
    condition     = contains(["management", "sub"], var.account_type)
    error_message = "Invalid account type. Must be 'management' or 'sub'."
  }
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
    condition     = contains(["cloudformation", "manual", "http"], var.registration_method)
    error_message = "Invalid registration method. Must be 'cloudformation', 'http' or 'manual'."
  }
}

variable "token" {
  type        = string
  sensitive   = true
  description = "(**Required for HTTP registration method**) The registration token provided by Attribute."
  default     = ""
}

variable "configure_eks_cost_allocation_tags" {
  type        = bool
  description = "(*Optional*) Whether to configure the EKS cost allocation tags. Default is 'true'. Enabling this option requires access to the AWS Cost Explorer API."
  default     = true
}

variable "configure_ecs_cost_allocation_tags" {
  type        = bool
  description = "(*Optional*) Whether to configure the ECS cost allocation tags. Default is 'true'. Enabling this option requires access to the AWS Cost Explorer API."
  default     = true
}

variable "logs_export_buckets" {
  type        = list(string)
  default     = []
  description = "(*Optional*) The list of S3 buckets to grant access to the Loader IAM Role for ingesting logs."
}

variable "resource_tags" {
  type        = map(map(string))
  default     = {}
  description = "(*Optional*) Additional tags to apply to specific resources created by the module."
}

variable "general_tags" {
  type        = map(string)
  default     = {}
  description = "(*Optional*) The tags to apply to the resources created by the module."
}

variable "cloudtrail_enabled" {
  type        = bool
  default     = false
  description = "(*Optional*) Whether to enable CloudTrail for the Loader IAM Role. Default is 'false'."
}
