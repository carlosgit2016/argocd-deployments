#!/bin/bash

## Build images and load into minikube pulling image and tag from docker-compose.yaml

set -e

docker compose build
minikube image load --overwrite=true "$(yq '.services.event-ledger.image' docker-compose.yaml)" # Load event-ledger image