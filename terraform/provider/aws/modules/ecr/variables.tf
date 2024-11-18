variable "repos" {
  type = map(any)
}

variable "policy" {
  default = <<EOF
{
  "rules": [
    {
      "action": {
        "type": "expire"
      },
      "selection": {
        "countType": "imageCountMoreThan",
        "countNumber": 50,
        "tagStatus": "any"
      },
      "description": "Keep no more than 50 images.",
      "rulePriority": 10
    }
  ]
}
EOF
}
