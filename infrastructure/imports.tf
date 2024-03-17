import {
  for_each = toset(local.ecr_repos)
  to       = module.main_resources[0].aws_ecr_repository.repo[each.value]
  id       = each.value
}
