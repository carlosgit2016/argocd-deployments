#!/bin/bash

set -e

echo "Password"
echo
kubectl get secret/argocd-initial-admin-secret -nargocd -ojson | jq -r '.data.password' | base64 -d

echo
echo
echo "Port forwarding"
echo

kubectl port-forward svc/argocd-server -nargocd 8080:http