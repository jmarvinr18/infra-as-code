resource "aws_ecr_repository" "ecr" {
  for_each = toset(var.repos)
  name     = each.key
  tags     = {}

  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "ecr" {
  for_each   = aws_ecr_repository.ecr
  repository = each.value.name
  policy     = var.policy
}
