# EKS provisioning through IaC

Exercise to provision an EKS cluster using Terraform

## References

https://developer.hashicorp.com/terraform/tutorials/kubernetes/eks  

https://www.youtube.com/watch?v=KE504NwP9vs (**Great reference**)  

 https://aws.amazon.com/blogs/aws/introducing-karpenter-an-open-source-high-performance-kubernetes-cluster-autoscaler/  

https://aws-quickstart.github.io/cdk-eks-blueprints/addons/cluster-autoscaler/  

Why Karpenter: https://www.youtube.com/watch?v=C-2v7HT-uSA  

EKS Blueprints for Terraform v5: https://aws-ia.github.io/terraform-aws-eks-blueprints/v4-to-v5/motivation/  

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
