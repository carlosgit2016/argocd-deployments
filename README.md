## Install kyverno to generate argocd secrets clusters
```bash
# Adding helm repo
helm repo add kyverno https://kyverno.github.io/kyverno/

# Installing chart
helm install kyverno kyverno/kyverno -n kyverno --create-namespace
```


