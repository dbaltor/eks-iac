#####################################################################################
#  This script is required as TF apply fails the first time due to ingresses 
#  being created whilst aws-load-balancer controller is still initialising
#####################################################################################
#!/bin/bash
set -eu

terraform init
until terraform apply -auto-approve; do
  echo Terraform apply has failed, retrying in 10 seconds...
  sleep 10
done