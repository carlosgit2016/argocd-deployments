locals {
  tags = {
    project = "argocd-deployments"
  }
}

resource "aws_ecr_repository" "worker" {
  name                 = "worker"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.tags

}

resource "aws_ecr_repository" "event-ledger" {
  name                 = "event-ledger"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = local.tags

}