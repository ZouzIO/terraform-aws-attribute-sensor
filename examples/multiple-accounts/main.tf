terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  alias = "mgmt"
}


provider "aws" {
  region = "us-east-1"

  alias = "sub-account-1"
}

provider "aws" {
  region = "us-east-1"

  alias = "sub-account-2"
}

provider "aws" {
  region = "us-east-1"

  alias = "sub-account-3"
}


resource "random_uuid" "external_id" {}


module "attribute-sensor-mgmt" {
  source  = "ZouzIO/attribute-sensor/aws"
  version = "~> 2.0"

  providers = {
    aws = aws.mgmt
  }

  account_name = "my-org-mgmt"
  account_type = "management"

  organization_id = var.organization_id

  external_id         = random_uuid.external_id.id
  registration_method = "cloudformation"
}

module "attribute-sensor-sub-1" {
  source  = "ZouzIO/attribute-sensor/aws"
  version = "~> 2.0"

  providers = {
    aws = aws.sub-account-1
  }

  account_name = "my-org-sub1"
  account_type = "sub"

  organization_id = var.organization_id

  external_id         = random_uuid.external_id.id
  registration_method = "cloudformation"
}

module "attribute-sub-2" {
  source  = "ZouzIO/attribute-sensor/aws"
  version = "~> 2.0"

  providers = {
    aws = aws.sub-account-2
  }

  account_name = "my-org-sub2"
  account_type = "sub"

  organization_id = var.organization_id

  external_id         = random_uuid.external_id.id
  registration_method = "cloudformation"
}

module "attribute-sub-3" {
  source  = "ZouzIO/attribute-sensor/aws"
  version = "~> 2.0"

  providers = {
    aws = aws.sub-account-3
  }

  account_name = "my-org-sub3"
  account_type = "sub"

  organization_id = var.organization_id

  external_id         = random_uuid.external_id.id
  registration_method = "cloudformation"
}
