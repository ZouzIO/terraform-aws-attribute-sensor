resource "aws_cloudformation_stack" "this" {
  count = var.registration_method == "cloudformation" ? 1 : 0
  name  = "AttributeRegistration"

  template_body = <<STACK
{
  "Resources": {
    "AttributeRegistration": {
      "Type": "Custom::ZouzRegistration",
      "Version": "0.2",
      "Properties": {
        "ServiceToken": "arn:aws:sns:us-east-1:405726414835:ZouzDeploymentRegistration",
        "AccountID": "${data.aws_caller_identity.current.account_id}",
        "CURBucket": "${aws_s3_bucket.this.bucket}",
        "CURPrefix": "${local.s3_prefix}",
        "Role": "${aws_iam_role.this.name}",
        "OrganizationID": "${var.organization_id}",
        "DeploymentID": "${var.deployment_id}",
        "DeploymentName": "${var.deployment_name}",
        "ExternalID": "${var.external_id}",
        "Version": "0.2"
      }
    }
  }
}
STACK
}
