variable "ecr_repos" {
  type = list(any)
}

variable "ecr_force_delete" {
  default = false
  type    = bool
}
