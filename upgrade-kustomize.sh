#!/bin/bash

# exit when any command fails
set -e

# Verify if new version was informed
APP_NAME=$1
ENV=$2
NEW_VER=$3
if [[ $# -eq 0 ]]; then
    read -n 1 -p "Application name, environment, and new version must be informed. Do you wish to continue? " answer
    echo
    case ${answer:0:1} in
        y|Y )
            echo Yes
            read -rep $'Please enter the application name:\n' APP
            echo
            read -rep $'Please enter the environment name:\n' ENV
            echo
            read -rep $'Please enter the new version:\n' NEW_VER
        ;;
        * )
            echo No
            exit 1
        ;;
    esac
elif [[ $# -ne 3 ]]; then
  echo "Application name, environment, and new version must be informed in this order."
  echo "E.g.: $0 <app-name> <env> <tag>"
  exit 1   
fi

echo "new version: $NEW_VER"

# Simulate release of the new docker images
docker tag nginx:1.25.2 dbaltor/nginx:$NEW_VER

# Push new version to dockerhub
docker push dbaltor/nginx:$NEW_VER

# Create temporary folder
TMP_DIR=$(mktemp -d)

# Clone GitHub repo
git clone git@github.com:dbaltor/argocd-test.git $TMP_DIR

# Update image tag
cd $TMP_DIR
sed -i "s/newTag: .*/newTag: ${NEW_VER}/g" ${TMP_DIR}/environments/${ENV}/${APP_NAME}/kustomization.yaml
# Commit and push
git add .
git commit -m "Upgrade image to $NEW_VER"
git push

# Optionally on build agents - remove folder
rm -rf $TMP_DIR
