- Create the repository - DONE
- Find a way to emulate multiple clusters - DONE
- Find a way to make the applicationset deploy to one of the vcluster - DONE
  - Used kyverno cluster policy to generate multiple argocd secrets from the vcluster secrets - DONE
- Create the microservice chart - DONE
- Create the clusters configuration - DONE
- Create the microservice applicationset - DONE
- Decorate the microservice override values - 
- Deploy rabbitmq in the cluster - DONE
- Control Kyverno through ArgoCD - DONE
- Deploy a new event-ledger microservice with a single HTTP endpoint that basically prints the events in their arrival - DONE
  - Print the request body - DONE
  - Write tests if any - DONE
  - Create a docker compose file to local development - DONE
  - Enable debug logs - DONE
- Write the worker microservice in Golang
  - microservice has to connect to a rabitmq instance - DONE
  - It should connect using SSL/TLS if supported instead of user/pass
  - Log using zap - DONE
  - for each new message it send to event ledger internal microservice using kube-dns address - DONE
- Create ECR repositories - DONE
- Configure pipeline to push images to the registries - DONE
- Deploy event-ledger through ArgoCD - DONE
- Deploy worker through ArgoCD
- Create a diagram to represent the infrastructure
- Start writing the article

### Additional
- Set policy to delete ECR images
- Set tag to be created based on conventional commits
- Set cache for docker build
- Reutilize the common library
- Figure out why builds to main do not trigger the pipeline
- Figure out why ECR registry image is with empty layers

## Challenge

- 
