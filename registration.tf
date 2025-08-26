resource "aws_cloudformation_stack" "registration" {
  count = var.registration_method == "cloudformation" ? 1 : 0

  name = "AttributeRegistration"

  template_body = jsonencode({
    Resources = {
      AttributeRegistration = {
        Type    = "Custom::AttributeRegistration"
        Version = "0.3"
        Properties = merge(
          {
            Version        = "0.3"
            ServiceToken   = "arn:aws:sns:us-east-1:405726414835:ZouzDeploymentRegistration"
            OrganizationID = "${var.organization_id}"
            AccountID      = "${data.aws_caller_identity.current.account_id}"
            AccountName    = "${var.account_name}"
            RoleName       = "${aws_iam_role.this.name}"
            ExternalID     = "${var.external_id}"
          },
          var.account_type == "management" ? {
            CURBucket     = "${aws_s3_bucket.this[0].bucket}"
            CURPrefix     = "${local.s3_prefix}"
            CURExportName = "${local.export_name}"
          } : {}
        )
      }
    }
  })

  tags = local.cloudformation_stack_tags
}

data "http" "attribute_registration" {
  count = var.registration_method == "http" ? 1 : 0
  request_headers = {
    "Content-Type"  = "application/json"
    "Authorization" = "Bearer ${var.token}",
  }

  url    = "https://sensor.app.attrb.io/api/v1/aws"
  method = "POST"

  request_body = jsonencode(merge(
    {
      "organization_id" = var.organization_id,
      "account_id"      = data.aws_caller_identity.current.account_id,
      "account_name"    = var.account_name,
      "role_name"       = aws_iam_role.this.name,
      "external_id"     = var.external_id
    },
    var.account_type == "management" ? {
      "cur_bucket"      = aws_s3_bucket.this[0].bucket,
      "cur_prefix"      = local.s3_prefix,
      "cur_export_name" = local.export_name
  } : {}))
}
