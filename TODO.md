- Create the repository - DONE
- Find a way to emulate multiple clusters - DONE
- Find a way to make the applicationset deploy to one of the vcluster - DONE
  - Used kyverno cluster policy to generate multiple argocd secrets from the vcluster secrets - DONE
- Create the microservice chart - DONE
- Create the clusters configuration - DONE
- Create the microservice applicationset - DONE
- Decorate the microservice override values - 
- Deploy rabbitmq in the cluster - DONE
- Control Kyverno through ArgoCD
- Deploy a new event-ledger microservice with a single HTTP endpoint that basically prints the events in their arrival
- Write the worker microservice in Golang
  - microservice has to connect to a rabitmq instance
  - for each new message it send to event ledger internal microservice using kube-dns address
- Create a diagram to represent the infrastructure
- Start writing the article

## Challenge
- 
