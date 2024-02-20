# resource "aws_iam_policy" "karpenter_controller_policy" {
#   name = "KarpenterControllerPolicy"

#   policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Sid": "AllowScopedEC2InstanceActions",
#       "Effect": "Allow",
#       "Resource": [
#         "arn:aws:ec2:${var.region}::image/*",
#         "arn:aws:ec2:${var.region}::snapshot/*",
#         "arn:aws:ec2:${var.region}:*:spot-instances-request/*",
#         "arn:aws:ec2:${var.region}:*:security-group/*",
#         "arn:aws:ec2:${var.region}:*:subnet/*",
#         "arn:aws:ec2:${var.region}:*:launch-template/*"
#       ],
#       "Action": [
#         "ec2:RunInstances",
#         "ec2:CreateFleet"
#       ]
#     },
#     {
#       "Sid": "AllowRegionalReadActions",
#       "Effect": "Allow",
#       "Resource": "*",
#       "Action": [
#         "ec2:DescribeAvailabilityZones",
#         "ec2:DescribeImages",
#         "ec2:DescribeInstances",
#         "ec2:DescribeInstanceTypeOfferings",
#         "ec2:DescribeInstanceTypes",
#         "ec2:DescribeLaunchTemplates",
#         "ec2:DescribeSecurityGroups",
#         "ec2:DescribeSpotPriceHistory",
#         "ec2:DescribeSubnets"
#       ],
#       "Condition": {
#         "StringEquals": {
#           "aws:RequestedRegion": "${var.region}"
#         }
#       }
#     },
#     {
#       "Sid": "AllowSSMReadActions",
#       "Effect": "Allow",
#       "Resource": "arn:aws:ssm:${var.region}::parameter/aws/service/*",
#       "Action": "ssm:GetParameter"
#     },
#     {
#       "Sid": "AllowPricingReadActions",
#       "Effect": "Allow",
#       "Resource": "*",
#       "Action": "pricing:GetProducts"
#     },
#     {
#       "Sid": "AllowInterruptionQueueActions",
#       "Effect": "Allow",
#       "Resource": "${module.karpenter.queue_arn}",
#       "Action": [
#         "sqs:DeleteMessage",
#         "sqs:GetQueueUrl",
#         "sqs:ReceiveMessage"
#       ]
#     },
#     {
#       "Sid": "AllowPassingInstanceRole",
#       "Effect": "Allow",
#       "Resource": "${module.karpenter.role_arn}",
#       "Action": "iam:PassRole",
#       "Condition": {
#         "StringEquals": {
#           "iam:PassedToService": "ec2.amazonaws.com"
#         }
#       }
#     },
#     {
#       "Sid": "AllowScopedInstanceProfileCreationActions",
#       "Effect": "Allow",
#       "Resource": "*",
#       "Action": [
#         "iam:CreateInstanceProfile"
#       ]
#     },
#     {
#       "Sid": "AllowScopedInstanceProfileTagActions",
#       "Effect": "Allow",
#       "Resource": "*",
#       "Action": [
#         "iam:TagInstanceProfile"
#       ]
#     },
#     {
#       "Sid": "AllowScopedInstanceProfileActions",
#       "Effect": "Allow",
#       "Resource": "*",
#       "Action": [
#         "iam:AddRoleToInstanceProfile",
#         "iam:RemoveRoleFromInstanceProfile",
#         "iam:DeleteInstanceProfile"
#       ]
#     },
#     {
#       "Sid": "AllowInstanceProfileReadActions",
#       "Effect": "Allow",
#       "Resource": "*",
#       "Action": "iam:GetInstanceProfile"
#     },
#     {
#       "Sid": "AllowAPIServerEndpointDiscovery",
#       "Effect": "Allow",
#       "Resource": "${module.eks.cluster_arn}",
#       "Action": "eks:DescribeCluster"
#     }
#   ]
# }
# POLICY
# }

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.21.0"

  cluster_name           = module.eks.cluster_name
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]
  # The next parameter can be removed (default false) if karpenter_controller_policy is used
  enable_karpenter_instance_profile_creation = true

  policies = {
    # you need to pick only one
    # this one goes with `enable_karpenter_instance_profile_creation = true` above
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    # KarpenterControllerPolicy = aws_iam_policy.karpenter_controller_policy.arn
  }

  tags = {
    Environment = "TESTING EKS"
  }
}

resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  chart               = "karpenter"
  version             = "v0.34.0"

  set {
    name  = "settings.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "settings.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.irsa_arn
  }

  set {
    name  = "settings.interruptionQueueName"
    value = module.karpenter.queue_name
  }

    depends_on = [
      module.eks,
      module.karpenter
    ]
}

resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = <<-YAML
# This example NodePool will provision general purpose instances
---
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata:
  name: general-purpose
  annotations:
    kubernetes.io/description: "General purpose NodePool for generic workloads"
spec:
  template:
    spec:
      nodeClassRef:
        name: default    
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
        - key: karpenter.k8s.aws/instance-category
          operator: In
          # values: ["c", "m", "r"]
          values: ["t"]          
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values: ["2"]
    limits:
      cpu: 1000
    disruption:
      consolidationPolicy: WhenEmpty
      consolidateAfter: 30s        
YAML

  depends_on = [helm_release.karpenter]
}

resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = <<-YAML
---
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata:
  name: default
  annotations:
    kubernetes.io/description: "General purpose EC2NodeClass for running Amazon Linux 2 nodes"
spec:
  amiFamily: AL2 # Amazon Linux 2
  role: ${module.karpenter.role_name}
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "${module.eks.cluster_name}"
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: "${module.eks.cluster_name}"
  tags:
    karpenter.sh/discovery: ${module.eks.cluster_name}        
YAML

  depends_on = [helm_release.karpenter]
}