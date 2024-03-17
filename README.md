## Getting started

### Pre-requisites
- minikube
- vcluster CLI
- Linux terminal


### Start minikube and scaffold
```bash
minikube start
cd helper-scripts
./scaffold.sh ## Will install argocd and create 3 clusters (alpha, beta and gamma)
```

## How to

### How to build a service locally in services/

```bash
./build.sh # This will build the svc image and load in minikube
```

### How to create main resources
Main resources are the ones that will likely exists in the long term and be found within infrastructure/main, to create then:
```bash
terraform workspace select main
terraform apply
```

### How to spin up ephemeral resources
Ephemeral resources can be deleted anytime to save `$` and they're within infrastructure/ephemeral, to create them in AWS you can run:
```bash
terraform workspace select ephemeral
terraform apply
```




## Throubleshooting

### Install kyverno to generate argocd secrets clusters
```bash
# Adding helm repo
helm repo add kyverno https://kyverno.github.io/kyverno/

# Installing chart
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```

### Create different secret for rabbitmq

Create a new secret and decorate it with rabbitmq-password
```bash
kubectl create secret generic rabbitmqpass
```

Decorate the `values.yaml` with the new secret reference
```yaml
existingPasswordSecret: "rabbitmqpass"
```

It will secure that the secrets don't get recreate, so the PersistentVolume don't have to be recreated as well to have the new secret

### Fix rabbitmq probe 401 unauthorized

If rabbitmq was initially created with a different password, it will fail the health checks

- Scale down
- Delete the pvc
- Delete the pv
- Scale up (pvc will create the pv again)
