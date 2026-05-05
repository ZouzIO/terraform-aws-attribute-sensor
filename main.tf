resource "aws_s3_bucket" "this" {
  count = var.account_type == "management" ? 1 : 0

  bucket = "${local.name_prefix}attribute-cur-${local.region}-${data.aws_caller_identity.current.account_id}"

  tags = local.s3_bucket_tags
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count = var.account_type == "management" ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }

  lifecycle {
    precondition {
      condition     = local.region == "us-east-1"
      error_message = "The region for the registration must be set us-east-1 (currently ${local.region}). Please update the region and try again."
    }
  }
}

resource "aws_s3_bucket_acl" "this" {
  count = var.account_type == "management" ? 1 : 0

  depends_on = [aws_s3_bucket_ownership_controls.this[0]]

  bucket = aws_s3_bucket.this[0].id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "this" {
  count = var.account_type == "management" ? 1 : 0

  bucket = aws_s3_bucket.this[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "AttributeCurBucketPolicy"
    Statement = [
      {
        Sid    = "CURBucketQuery"
        Effect = "Allow"
        Principal = {
          Service = [
            "billingreports.amazonaws.com",
            "bcm-data-exports.amazonaws.com"
          ]
        }
        Action = [
          "s3:PutObject",
          "s3:GetBucketPolicy"
        ]
        Resource = [
          aws_s3_bucket.this[0].arn,
          "${aws_s3_bucket.this[0].arn}/*",
        ]
        Condition = {
          StringLike = {
            "aws:SourceArn" = [
              "arn:aws:cur:${local.region}:${data.aws_caller_identity.current.account_id}:definition/*",
              "arn:aws:bcm-data-exports:${local.region}:${data.aws_caller_identity.current.account_id}:export/*"
            ]
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      }
    ]
    }
  )
}
resource "aws_iam_role" "this" {
  name = "${local.name_prefix}AttributeLoaderV-${local.region}-${data.aws_caller_identity.current.account_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::405726414835:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })

  tags = local.iam_role_tags
}

resource "aws_iam_role_policy" "this" {
  name = "ResourceAccessor"
  role = aws_iam_role.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      local.management_billing_statements,
      local.base_statements,
      local.cur_reader,
      local.exported_logs_reader,
      local.cloudtrail_reader
    )
  })
}

resource "aws_iam_role_policy" "additional" {
  count = length(var.additional_policy) > 0 ? 1 : 0

  name   = "Additional"
  role   = aws_iam_role.this.id
  policy = var.additional_policy
}

resource "aws_ce_cost_allocation_tag" "eks" {
  for_each = (var.configure_eks_cost_allocation_tags && var.account_type == "management") ? toset(local.eks_cost_allocation_tags) : []

  tag_key = each.key
  status  = "Active"
}

resource "aws_ce_cost_allocation_tag" "ecs" {
  for_each = (var.configure_ecs_cost_allocation_tags && var.account_type == "management") ? toset(local.ecs_cost_allocation_tags) : []

  tag_key = each.key
  status  = "Active"
}

resource "aws_bcmdataexports_export" "this" {
  count = var.account_type == "management" ? 1 : 0

  export {
    name        = local.export_name
    description = local.export_name
    data_query {
      query_statement = file(local.bcm_query_file_path)

      table_configurations = {
        COST_AND_USAGE_REPORT = {
          BILLING_VIEW_ARN                      = "arn:aws:billing::${data.aws_caller_identity.current.account_id}:billingview/primary"
          TIME_GRANULARITY                      = "HOURLY",
          INCLUDE_RESOURCES                     = "TRUE",
          INCLUDE_MANUAL_DISCOUNT_COMPATIBILITY = "FALSE",
          INCLUDE_SPLIT_COST_ALLOCATION_DATA    = var.managed_by_reseller ? "FALSE" : "TRUE",
        }
      }
    }
    destination_configurations {
      s3_destination {
        s3_bucket = aws_s3_bucket.this[0].bucket
        s3_prefix = local.s3_prefix
        s3_region = aws_s3_bucket.this[0].region
        s3_output_configurations {
          overwrite   = "OVERWRITE_REPORT"
          format      = "PARQUET"
          compression = "PARQUET"
          output_type = "CUSTOM"
        }
      }
    }

    refresh_cadence {
      frequency = "SYNCHRONOUS"
    }
  }

  tags = local.bcm_data_exports_tags

  # To avoid "S3 bucket permission validation failed"
  depends_on = [
    aws_s3_bucket_policy.this,
    aws_s3_bucket_acl.this,
    aws_s3_bucket_ownership_controls.this,
  ]
}
