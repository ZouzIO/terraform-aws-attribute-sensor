variable "organization_id" {
  type        = string
  description = "(Required) The Organization ID provided by Attribute"
}

variable "account_name" {
  type        = string
  description = "(Required) The AWS Account name"
  default     = ""
}

variable "name_prefix" {
  type        = string
  description = "(*Optional*) The prefix to use for naming resources created by the module."
  default     = ""
}

variable "account_type" {
  type        = string
  description = "(Required) The AWS Account type. Available options are: 'management' or 'sub'."
}


variable "general_tags" {
  type        = map(string)
  description = "(*Optional*) A map of tags to assign to resources created by the module."
  default     = {}
}

variable "registration_method" {
  type        = string
  description = "(*Optional*) The registration method to use. Available options are: 'cloudformation' or 'manual'. Default is 'cloudformation'."
  default     = "cloudformation"
}

variable "token" {
  type        = string
  sensitive   = true
  description = "(**Required for HTTP registration method**) The registration token provided by Attribute."
  default     = ""
}
