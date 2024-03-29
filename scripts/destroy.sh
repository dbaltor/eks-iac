#####################################################################################
#  This script is used to remove all app with its albs before running tf destroy
#####################################################################################
#!/bin/bash
set -eu

# remove apps deployed by argocd
terraform destroy -auto-approve -target kubectl_manifest.my_app_staging \
-target kubectl_manifest.my_app_prod \
-target kubectl_manifest.nginx_helm \
-target kubectl_manifest.apps_dev \
-target kubectl_manifest.apps_staging \
-target kubectl_manifest.apps_prod \
-target kubernetes_namespace.superset

# remove argocd itself
terraform destroy -auto-approve -target kubernetes_namespace.argocd

# remove prometheus and grafana
terraform destroy -auto-approve --target module.eks_blueprints_addons.module.kube_prometheus_stack.helm_release.this
sleep 60

# destroy everything else
terraform destroy -auto-approve

# force secret deletion so the name can be immediatelly reused
AWS_PAGER="" aws secretsmanager delete-secret --secret-id prod/superset --force-delete-without-recovery --region $(aws configure get region)

