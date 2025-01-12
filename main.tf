resource "aws_s3_bucket" "this" {
  bucket = "attribute-cur-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }

  lifecycle {
    precondition {
      condition     = data.aws_region.current.name == "us-east-1"
      error_message = "The region for the registration must be set us-east-1 (currently ${data.aws_region.current.name}). Please update the region and try again."
    }
  }
}

resource "aws_s3_bucket_acl" "this" {
  depends_on = [aws_s3_bucket_ownership_controls.this]

  bucket = aws_s3_bucket.this.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id

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
          aws_s3_bucket.this.arn,
          "${aws_s3_bucket.this.arn}/*",
        ]
        Condition = {
          StringLike = {
            "aws:SourceArn" = [
              "arn:aws:cur:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:definition/*",
              "arn:aws:bcm-data-exports:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:export/*"
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
  name = "AttributeLoaderV-${data.aws_region.current.name}"

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

  inline_policy {
    name = "ResourceAccessor"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = concat(
        local.base_statements,
        local.exported_logs_reader
      )
    })
  }
}

resource "aws_ce_cost_allocation_tag" "eks" {
  for_each = var.configure_eks_cost_allocation_tags ? toset(local.eks_cost_allocation_tags) : []

  tag_key = each.key
  status  = "Active"
}

resource "aws_ce_cost_allocation_tag" "ecs" {
  for_each = var.configure_ecs_cost_allocation_tags ? toset(local.ecs_cost_allocation_tags) : []

  tag_key = each.key
  status  = "Active"
}

resource "aws_bcmdataexports_export" "this" {
  count = var.registration_method == "manual" ? 1 : 0
  export {
    name        = "AttributeCurExport"
    description = "AttributeCurExport"
    data_query {
      query_statement = file("${path.module}/files/bcm_cur_query.sql")

      table_configurations = {
        COST_AND_USAGE_REPORT = {
          TIME_GRANULARITY                      = "HOURLY",
          INCLUDE_RESOURCES                     = "TRUE",
          INCLUDE_MANUAL_DISCOUNT_COMPATIBILITY = "FALSE",
          INCLUDE_SPLIT_COST_ALLOCATION_DATA    = "TRUE",
        }
      }
    }
    destination_configurations {
      s3_destination {
        s3_bucket = aws_s3_bucket.this.bucket
        s3_prefix = local.s3_prefix
        s3_region = aws_s3_bucket.this.region
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
}
