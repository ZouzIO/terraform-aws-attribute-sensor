locals {
  eks_cost_allocation_tags = [
    "aws:autoscaling:groupName",
    "aws:eks:cluster-name"
  ]

  ecs_cost_allocation_tags = [
    "aws:ecs:clusterName",
    "aws:ecs:serviceName",
  ]

  s3_prefix = "attributeexport"

  export_name = "${local.name_prefix}AttributeCurExport"

  logs_export_buckets = flatten([
    for bucket in var.logs_export_buckets : [
      bucket,
      "${bucket}/*"
    ]
  ])

  base_statements = [
    {
      Sid    = "CURExportCreator"
      Effect = "Allow"
      Action = "bcm-data-exports:CreateExport"
      Resource = [
        "arn:aws:bcm-data-exports:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:export/*",
        "arn:aws:bcm-data-exports:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:table/COST_AND_USAGE_REPORT"
      ]
    },
    {
      Sid    = "CURExportDefinitionPlacer"
      Effect = "Allow"
      Action = "cur:putReportDefinition"
      Resource = [
        "arn:aws:cur:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:/putReportDefinition"
      ]
    },
    {
      Sid    = "CURTagsSetter"
      Effect = "Allow"
      Action = [
        "ce:ListCostAllocationTags",
        "ce:UpdateCostAllocationTagsStatus"
      ]
      Resource = "*"
    },
    {
      Sid    = "MetricsViewer"
      Effect = "Allow"
      Action = [
        "cloudwatch:GetMetricData"
      ]
      Resource = "*"
    },
    {
      Sid    = "S3Explorer"
      Effect = "Allow"
      Action = [
        "s3:GetBucketLocation",
        "s3:GetBucketPolicy",
        "s3:GetBucketTagging",
        "s3:GetBucketVersioning",
        "s3:GetIntelligentTieringConfiguration",
        "s3:GetInventoryConfiguration",
        "s3:GetLifecycleConfiguration",
        "s3:ListBucketVersions",
        "s3:GetBucketLocation",
        "s3:DescribeBuckets"
      ]
      Resource = "*"
    },
    {
      Sid    = "AWSDescriber"
      Effect = "Allow"
      Action = [
        "ec2:List*",
        "ec2:Describe*",
        "ec2:GetManagedPrefixListEntries",
        "ec2:SearchTransitGatewayRoutes",
        "ecs:List*",
        "ecs:Describe*",
        "eks:List*",
        "eks:Describe*",
        "rds:List*",
        "rds:Describe*",
        "elasticloadbalancing:List*",
        "elasticloadbalancing:Describe*",
        "dynamodb:List*",
        "dynamodb:Describe*",
        "elasticloadbalancing:List*",
        "elasticloadbalancing:Describe*",
        "s3:List*",
        "s3:Describe*",
        "elasticfilesystem:List*",
        "elasticfilesystem:Describe*",
        "elasticache:List*",
        "elasticache:Describe*",
        "lambda:List*",
        "lambda:Describe*",
        "memorydb:List*",
        "memorydb:Describe*",
        "neptune-db:List*",
        "neptune-db:Describe*",
        "redshift:List*",
        "redshift:Describe*",
        "kafka:Get*",
        "kafka:List*",
        "kafka:Describe*",
        "es:Describe*",
        "es:List*",
        "aoss:List*",
        "osis:List*",
        "bedrock:Get*",
        "bedrock:List*"
      ]
      Resource = "*"
    },
    {
      Sid    = "CostRecommendationViewer"
      Effect = "Allow"
      Action = [
        "ce:Get*",
        "ce:List*",
        "ce:ListCostAllocationTags",
        "ce:UpdateCostAllocationTagsStatus",
        "ce:GetReservationCoverage",
        "ce:GetReservationPurchaseRecommendation",
        "ce:GetReservationUtilization",
        "ce:GetRightsizingRecommendation",
        "ce:GetSavingsPlansPurchaseRecommendation",
        "ce:GetSavingsPlansCoverage",
        "ce:GetSavingsPlansUtilization",
        "ce:StartSavingsPlansPurchaseRecommendationGeneration",
        "cost-optimization-hub:ListRecommendations"
      ]
      Resource = "*"
    }
  ]

  exported_logs_reader = length(local.logs_export_buckets) > 0 ? [
    {
      Sid    = "ExportedLogsReader"
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = local.logs_export_buckets
    }
  ] : []

  cur_reader = var.account_type == "management" ? [
    {
      Sid    = "CURReader"
      Effect = "Allow"
      Action = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      Resource = [
        aws_s3_bucket.this[0].arn,
        "${aws_s3_bucket.this[0].arn}/${local.s3_prefix}/*"
      ]
    },
  ] : []

  cloudtrail_reader = var.cloudtrail_enabled ? [
    {
      Sid      = "CloudTrailReader"
      Effect   = "Allow"
      Action   = "cloudtrail:LookupEvents"
      Resource = "*"
    },
  ] : []
  s3_bucket_tags            = merge(try(var.resource_tags["s3_bucket"], {}), var.general_tags)
  iam_role_tags             = merge(try(var.resource_tags["iam_role"], {}), var.general_tags)
  cloudformation_stack_tags = merge(try(var.resource_tags["cloudformation_stack"], {}), var.general_tags)
  bcm_data_exports_tags     = merge(try(var.resource_tags["bcmdataexports_export"], {}), var.general_tags)
  name_prefix               = length(var.name_prefix) > 0 ? "${var.name_prefix}-" : ""
}
