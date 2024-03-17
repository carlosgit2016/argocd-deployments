locals {
  tags = {
    project = "argocd-deployments"
  }
}

resource "aws_ecr_repository" "repo" {

  for_each = toset(var.ecr_repos)

  name                 = each.value
  image_tag_mutability = "MUTABLE"
  force_delete         = var.ecr_force_delete

  image_scanning_configuration {
    scan_on_push = true
  }

  lifecycle {
    create_before_destroy = false
  }

  tags = local.tags

}
