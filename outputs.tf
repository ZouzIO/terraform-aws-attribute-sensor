output "cur_s3_bucket_arn" {
  description = "The S3 bucket where the CUR 2.0 reports are stored."
  value       = aws_s3_bucket.this.arn
}

output "loader_iam_role_arn" {
  description = "The IAM role used by the loader to access the CUR 2.0 data."
  value       = aws_iam_role.this.arn
}

output "cur_s3_bucket_policy_id" {
  description = "The S3 bucket policy applied to the CUR 2.0 bucket."
  value       = aws_s3_bucket_policy.this.id
}

output "external_id" {
  sensitive   = true
  description = "The External ID used to assume the Loader IAM Role."
  value       = var.external_id
}
