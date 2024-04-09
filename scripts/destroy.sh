#!/bin/bash
#####################################################################################
#  This script is used to remove all app with its albs before running tf destroy
#####################################################################################
set -eu

echo "==============================================================================================================="
echo "WARNING: This is going to destroy your EKS cluster!!!"
echo "==============================================================================================================="
echo
read -n1 -sp "Do you really want to continue(Y/N)?" answer
echo
case ${answer:0:1} in
    y|Y )
        echo Yes
    ;;
    * )
        echo No
        exit 1
    ;;
esac

cd $(dirname $0)
cd ..

# remove apps deployed by argocd
terraform destroy -auto-approve -target kubectl_manifest.my_app_staging \
-target kubectl_manifest.my_app_prod \
-target kubectl_manifest.nginx_helm \
-target kubectl_manifest.apps_dev \
-target kubectl_manifest.apps_staging \
-target kubectl_manifest.apps_prod \
-target kubernetes_namespace.superset
echo "Waiting 30 seconds..."
sleep 30

# remove argocd itself
terraform destroy -auto-approve -target kubernetes_namespace.argocd
echo "Waiting 30 seconds..."
sleep 30

# remove prometheus and grafana
terraform destroy -auto-approve --target module.eks_blueprints_addons.module.kube_prometheus_stack.helm_release.this[0]
echo "Waiting 30 seconds..."
sleep 30

# destroy everything else
until terraform destroy -auto-approve; do
  echo Terraform destroy has failed, retrying in 10 seconds...
  sleep 10
done

# force secret deletion so the name can be immediatelly reused
AWS_PAGER="" aws secretsmanager delete-secret --secret-id prod/superset --force-delete-without-recovery --region $(aws configure get region)

