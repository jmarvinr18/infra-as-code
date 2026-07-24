resource "aws_organizations_policy" "this" {
  name        = var.name
  description = var.description
  type        = var.type

  content = var.content == "string" ? var.content : file(var.content)

}

# Attach to the Clients OU so every client account inherits it.
resource "aws_organizations_policy_attachment" "this" {
  policy_id = aws_organizations_policy.this.id
  target_id = var.organization_ou_client_id
}