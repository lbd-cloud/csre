#!/bin/bash

CLUSTER_NAME="csre-cluster"
ZONE="csre-cluster-zone"
PROJECT="csre-gcp-project"

# Get credentials and encode in base64
gcloud container clusters get-credentials $CLUSTER_NAME --zone $ZONE --project $PROJECT
KUBECONFIG_CONTENT=$(cat ~/.kube/config | base64)

# Output the base64 string
echo "Encoded kubeconfig: $KUBECONFIG_CONTENT"

# Instructions to store in GitHub Secrets
echo "Store the above base64-encoded string in a GitHub secret named KUBECONFIG_BASE64"
