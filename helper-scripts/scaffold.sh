#!/bin/bash

set -eo pipefail

function install_argocd(){
    kubectl get ns argocd 2> /dev/null
    if [ $? -eq 1 ]; then
        kubectl create namespace argocd
    fi
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
}

function install_vcluster(){

    clusters=$(yq '.[].name' clusters_list.yaml)

    for cluster in $clusters; do
        vcluster create "$cluster" --context minikube
    done

    vcluster disconnect

}

function main() {
    install_argocd
    install_vcluster
}

main
