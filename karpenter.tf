module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.16.0"

  cluster_name           = module.eks.cluster_name
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]

  policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
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
  version             = "v0.30.0"

  set {
    name  = "settings.aws.clusterName"
    value = module.eks.cluster_name
  }

  set {
    name  = "settings.aws.clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter.irsa_arn
  }

  set {
    name  = "settings.aws.defaultInstanceProfile"
    value = module.karpenter.instance_profile_name
  }

  set {
    name  = "settings.aws.interruptionQueueName"
    value = module.karpenter.queue_name
  }
}

resource "kubectl_manifest" "karpenter_provisioner" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1alpha5
    kind: Provisioner
    metadata:
      name: default
    spec:
      ttlSecondsAfterEmpty: 30 # scale down nodes after 30 seconds without workloads (excluding daemons)
      ttlSecondsUntilExpired: 604800 # expire nodes after 7 days (in seconds) = 7 * 60 * 60 * 24
      # Resource limits constrain the total size of the cluster.
      # limits:
      #   resources:
      #   cpu: 32
      #   memory: 100Gi
      requirements:
        # Include general purpose instance families
        - key: karpenter.k8s.aws/instance-family
          operator: In
          values: [t3]   
          # values: [c5, m5, r5]   
        # Exclude small instance sizes
        # - key: karpenter.k8s.aws/instance-size
        #   operator: NotIn
        #   values: [nano, micro, small]
      providerRef:
        name: default
  YAML

  depends_on = [helm_release.karpenter]
}

resource "kubectl_manifest" "karpenter_node_template" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1alpha1
    kind: AWSNodeTemplate
    metadata:
      name: default
    spec:
      subnetSelector:
        "kubernetes.io/cluster/${module.eks.cluster_name}": "owned"
      securityGroupSelector:
        "kubernetes.io/cluster/${module.eks.cluster_name}": "owned"
      instanceProfile: ${module.karpenter.instance_profile_name}  
      tags:
        "karpenter.sh/discovery": "${module.eks.cluster_name}" 
  YAML

  depends_on = [helm_release.karpenter]
}

