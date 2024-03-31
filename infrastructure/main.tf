locals {
  ecr_repos    = ["worker", "event-ledger", "aws-token-refresher"]
  is_main      = terraform.workspace == "main"
  is_ephemeral = terraform.workspace == "ephemeral"
}

module "ephemeral_resources" {
  count  = local.is_ephemeral ? 1 : 0
  source = "./ephemeral"
}

module "main_resources" {
  count     = local.is_main ? 1 : 0
  source    = "./main"
  ecr_repos = local.ecr_repos
}

# MAIN Outputs
output "main_oidc_role_arn" {
  value = local.is_main ? module.main_resources[0].oidc_role_arn : ""
  depends_on = [
    module.main_resources
  ]
}
