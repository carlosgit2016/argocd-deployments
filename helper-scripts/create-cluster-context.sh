#!/bin/bash

# Script to create Kubernetes secrets for all vclusters extracting it from the kubectl config

create_k8s_secret() {
    local vcluster_name="vcluster_$1"

    local context_cluster_name
    local server_url
    local ca_data
    local cert_data
    local key_data
    local secret_name

    context_cluster_name=$(kubectl config view -ojson | jq -r ".contexts[] | select(.name | contains(\"$vcluster_name\")).context.cluster")
    vcluster_cluster_ns=$(vcluster list --output json | jq -r ".[] | select(.Name==\"$1\").Namespace")
    server_url="https://$1.$vcluster_cluster_ns"
    ca_data=$(kubectl config view --raw -o jsonpath="{.clusters[?(@.name=='$context_cluster_name')].cluster.certificate-authority-data}")
    cert_data=$(kubectl config view --raw -o jsonpath="{.users[?(@.name=='$context_cluster_name')].user.client-certificate-data}")
    key_data=$(kubectl config view --raw -o jsonpath="{.users[?(@.name=='$context_cluster_name')].user.client-key-data}")
    insecure="false"

    secret_name=$(tr '_' '.'<<<"${context_cluster_name:0:63}") # Truncate at char 63 and remove _
    
    if [ ! -e vcluster_secrets ]; then
        mkdir vcluster_secrets
    fi

    kubectl create secret generic "$secret_name" \
        --from-literal=name="$secret_name" \
        --from-literal=server="$server_url" \
        --from-literal=config="{\"config\": {\"tlsClientConfig\": {\"caData\": \"$ca_data\", \"certData\": \"$cert_data\", \"insecure\": \"$insecure\", \"keyData\": \"$key_data\"}}}" \
        --dry-run=client -o yaml -nargocd > "vcluster_secrets/$secret_name.yaml"

    yq eval '.metadata.labels."argocd.argoproj.io/secret-type" = "cluster"' -i "vcluster_secrets/$secret_name.yaml" # Patch the secret so argocd will be able to identify

}

main() {
    # Iterate through vcluster list
    vcluster_clusters=$(vcluster list --output json | jq -r '.[].Name')
    for vcluster_name in $vcluster_clusters; do
        create_k8s_secret "$vcluster_name"
    done
}

set -eo pipefail
main
