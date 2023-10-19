# EKS provisioning through IaC

## Provisioning an EKS cluster using Terraform

Adapted from https://www.youtube.com/watch?v=KE504NwP9vs

### Further References

https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks  
 
https://aws.amazon.com/blogs/aws/introducing-karpenter-an-open-source-high-performance-kubernetes-cluster-autoscaler/  

https://aws-quickstart.github.io/cdk-eks-blueprints/addons/cluster-autoscaler/  

Why Karpenter:  
https://www.youtube.com/watch?v=C-2v7HT-uSA  

EKS Blueprints for Terraform v5:  
https://aws-ia.github.io/terraform-aws-eks-blueprints/v4-to-v5/motivation/  

Most notably:  
>With this shift in direction, the cluster definition will be removed from the project and instead examples will reference the terraform-aws-eks module for cluster creation. The remaining modules will be moved out to their own respective repositories as standalone projects.  

AWS EKS Terraform module:  
https://github.com/terraform-aws-modules/terraform-aws-eks

EKS Blueprints Addons:  
https://github.com/aws-ia/terraform-aws-eks-blueprints-addons 

https://aws.amazon.com/ec2/instance-types/t3/

https://docs.aws.amazon.com/eks/latest/userguide/sec-group-reqs.html 

Configure EBS policy on EKS nodes:  
https://github.com/ElliotG/coder-oss-tf/blob/main/aws-eks/main.tf  

Cluster Autoscaler:  
https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md  

https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html


## Installing Prometheus Agent and Graphana

Adapted from https://www.youtube.com/watch?v=-nUQNFAX5TI 

### Architecture Overview

![](./pictures/Managed%20Prometheus%20with%20Local%20Grafana.png)

### Further References

#### Prometheus
https://prometheus.io/docs/introduction/overview/  
  
https://aws.amazon.com/blogs/mt/getting-started-amazon-managed-service-for-prometheus/  


EKS blueprints addons - Terraform Prometheus stack:  
https://registry.terraform.io/modules/aws-ia/eks-blueprints-addons/aws/latest  
https://registry.terraform.io/modules/sparkfabrik/prometheus-stack/sparkfabrik/latest  (alternative) Repo  
  
Prometheus Agent:  
https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/designs/prometheus-agent.md  

Remote Write:  
https://grafana.com/docs/grafana-cloud/monitor-infrastructure/kubernetes-monitoring/configuration/configure-infrastructure-manually/prometheus/remote-write-operator/  
  
kube-prometheus-stack default values:  
https://github.com/prometheus-community/helm-charts/blob/main/charts/kube-prometheus-stack/values.yaml  
  
Managed Prometheus workspace:  
https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/prometheus_workspace  
  
https://aws.amazon.com/prometheus/pricing/  

#### Grafana:
Default values and format:  
https://github.com/grafana/helm-charts/blob/main/charts/grafana/values.yaml  
  
Solving two default dashboards issue:  
https://github.com/prometheus-community/helm-charts/issues/2251#issuecomment-1178789922  
  
Solving SigV4 authentication issue:  
https://github.com/prometheus-community/helm-charts/issues/2092#issuecomment-1140317696  

#### Fluent-bit
  
https://docs.fluentbit.io/manual/installation/kubernetes  
  
https://aws.amazon.com/blogs/containers/kubernetes-logging-powered-by-aws-for-fluent-bit/  
  
https://www.youtube.com/watch?v=KJlWV5-o8v0  
  
https://www.studytonight.com/post/configure-fluent-bit-with-aws-elasticsearch-service  
  
https://github.com/aws/aws-for-fluent-bit/issues/286  
  
https://docs.fluentbit.io/manual/pipeline/outputs/opensearch  
  
https://docs.aws.amazon.com/opensearch-service/latest/developerguide/configure-client-fluentbit.html  
  
Fluent-bit helm values:  
https://github.com/fluent/helm-charts/blob/main/charts/fluent-bit/values.yaml  
  
aws-for-fluent-bit helm values:  
https://github.com/aws/eks-charts/blob/master/stable/aws-for-fluent-bit/README.md  
  
Fluent-bit via Terraform:  
https://www.youtube.com/watch?v=kUyLghPG2AI  
https://github.com/quickbooks2018/terraform-aws-eks-logging/blob/79f8a96616d0239d7df28685acdc2747c622578f/main.tf  
  
https://www.youtube.com/watch?v=E_P4EqJQ-T0
https://github.com/raj13aug/eks-fluentbit/blob/c433853899994ddb54d2782d6be804a9731d94f5/main.tf  
  
Couldn't use OpenSearch OUTPUT due to the error below:
https://github.com/fluent/fluent-bit/issues/2714  
  
I did manage to configure OpenSearch OUTPUT in aws-for-fluent-bit image using the values I found in the repo below:
https://github.com/kabisa/terraform-aws-eks-cloudwatch/blob/6354db1244b719c31fd862e7142f116d08fcf894/yamls/fluentbit-values.yaml

#### ArgoCD

Great reference:  
https://www.youtube.com/watch?v=zGndgdGa1Tc  

To deploy the applications use:  
`./upgrade-apps.sh <version>`  
(for my-app-1 and my-app-2)  
  
`./upgrade-kustomize.sh <name> <env> <version>`  
(for my-app-3 or my-app-4 into staging or prod)