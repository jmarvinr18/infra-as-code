resource "google_project" "this" {
  for_each = var.projects

  name       = each.value.project_name
  project_id = each.value.project_id

  # org_id and folder_id are mutually exclusive: a folder wins when it is set.
  org_id    = var.folder_id == "" ? var.org_id : null
  folder_id = var.folder_id == "" ? null : var.folder_id

  # Left empty the project is created unlinked, so projects can be built
  # before the billing account is sorted out.
  billing_account = var.billing_account == "" ? null : var.billing_account

  labels = each.value.labels

  auto_create_network = var.auto_create_network

  # PREVENT is the provider default: flip to DELETE before tearing these down.
  deletion_policy = var.deletion_policy
}
