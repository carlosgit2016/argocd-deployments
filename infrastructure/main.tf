locals {
  ecr_repos = ["worker", "event-ledger", "aws-token-refresher"]
}

module "ephemeral_resources" {
  count  = terraform.workspace == "ephemeral" ? 1 : 0
  source = "./ephemeral"
}

module "main_resources" {
  count     = terraform.workspace == "main" ? 1 : 0
  source    = "./main"
  ecr_repos = local.ecr_repos
}
