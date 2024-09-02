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
}
