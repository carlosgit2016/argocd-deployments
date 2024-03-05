#!/bin/bash

AWS_ACCOUNT_ID="169740125934"
AWS_DEFAULT_REGION="us-east-1"

EXISTS=$(kubectl get secret "aws-ecr" | tail -n 1 | cut -d ' ' -f 1)
if [ "$EXISTS" = "aws-ecr" ]; then
  echo "Secret exists, deleting"
  kubectl delete secrets "aws-ecr"
fi

PASS=$(aws ecr get-login-password --region $AWS_DEFAULT_REGION)
kubectl create secret docker-registry aws-ecr \
    --docker-server="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_DEFAULT_REGION.amazonaws.com" \
    --docker-username=AWS \
    --docker-password="$PASS" \
    --docker-email=gabrielggff25@gmail.com --namespace default