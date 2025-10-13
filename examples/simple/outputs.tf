output "cur_s3_bucket_arn" {
  description = "The S3 bucket where the CUR 2.0 reports are stored."
  value       = var.account_type == "management" ? module.attribute_sensor.cur_s3_bucket_arn : null
}

output "cur_export_name" {
  description = "The name of the CUR 2.0 report definition."
  value       = var.account_type == "management" ? module.attribute_sensor.cur_export_name : null
}

output "cur_prefix" {
  description = "The prefix within the S3 bucket where the CUR 2.0 reports are stored."
  value       = var.account_type == "management" ? module.attribute_sensor.cur_prefix : null
}

output "loader_iam_role_arn" {
  description = "The IAM role used by the loader to access the CUR 2.0 data."
  value       = module.attribute_sensor.loader_iam_role_arn
}

output "external_id" {
  sensitive   = true
  description = "The External ID used to assume the Loader IAM Role."
  value       = module.attribute_sensor.external_id
}
