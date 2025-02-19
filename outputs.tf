output "cur_s3_bucket_arn" {
  description = "The S3 bucket where the CUR 2.0 reports are stored."
  value       = var.account_type == "management" ? aws_s3_bucket.this[0].arn : null
}

output "loader_iam_role_arn" {
  description = "The IAM role used by the loader to access the CUR 2.0 data."
  value       = aws_iam_role.this.arn
}

output "cur_s3_bucket_policy_id" {
  description = "The S3 bucket policy applied to the CUR 2.0 bucket."
  value       = var.account_type == "management" ? aws_s3_bucket_policy.this[0].id : null
}

output "external_id" {
  sensitive   = true
  description = "The External ID used to assume the Loader IAM Role."
  value       = var.external_id
}
