## Provision an AWS Managed ElasticSearch cluster

# module "elasticsearch" {
#   source                  = "cloudposse/elasticsearch/aws"
#   version                 = "0.44.0"
#   stage                   = "dev"
#   name                    = "es"
#   security_groups         = [module.vpc.default_security_group_id,module.eks.cluster_security_group_id]
#   vpc_id                  = module.vpc.vpc_id
#   subnet_ids              = module.vpc.private_subnets
#   availability_zone_count = 3
#   zone_awareness_enabled  = true
#   elasticsearch_version   = "7.7"
#   instance_type           = "t3.small.elasticsearch"
#   instance_count          = 3
#   ebs_volume_size         = 10
#   create_iam_service_linked_role = true # Set it to false if you already have an ElasticSearch cluster created in the AWS account and AWSServiceRoleForAmazonElasticsearchService already exist.
#   iam_role_arns           = [
#     aws_iam_role.fluent_bit.arn
#   ]
#   iam_actions             = ["es:*"]
#   encrypt_at_rest_enabled = true
#   kibana_subdomain_name   = "kibana-es"

#   depends_on = [aws_iam_role.fluent_bit]
# }
