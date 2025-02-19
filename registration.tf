resource "aws_cloudformation_stack" "this" {
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
}
