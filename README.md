## How to

### How to build a service locally in services/

```bash
./build.sh # This will build the svc image and load in minikube
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