# GCP provider tree — handoff notes

## Task

Build a Terraform provider tree for GCP, mirroring the existing AWS one:

```
terraform/provider/
├── aws/
│   └── modules/          ← existing pattern mirrored
└── gcp/                  ← NEW
    ├── modules/          ← reusable GCP resources, same structure as aws/modules
    └── organizations/
        └── orobo-tech/   ← initial org, root configs that consume the modules
```

## What the GCP modules cover

Goal: `orobo-prod`, `orobo-staging`, `orobo-shared` projects under one Org/billing
account, with billing protected by budget alerts.

- **`modules/projects/project`** — creates GCP projects under an Org or Folder, with
  `env` and `app` labels applied at creation (`env`: prod|staging|shared, `app`: orobo).
- **`modules/projects/services`** — enables a configurable list of APIs on each project
  (baseline: cloudresourcemanager, cloudbilling, billingbudgets, iam, compute,
  storage, monitoring, logging).
- **`modules/budgets/budget`** — one `google_billing_budget` scoped to the billing
  account (covering all three projects to start, not split per-project yet), with:
  - Threshold rules at 50% / 80% / 100%
  - A `google_monitoring_notification_channel` (email) wired via
    `all_updates_rule.monitoring_notification_channels`
  - `disable_default_iam_recipients = false` (keep built-in billing-admin emails
    active alongside the custom channel)
- **`modules/labels`** — the GCP counterpart of `aws/modules/tags`.
- **`modules/storage/bucket`** — GCS bucket, used by `state-bootstrap` the same way
  `aws/modules/s3/bucket` is.

## Layout

Mirrors `aws/organizations/krunchie-kreates`:

```
organizations/orobo-tech/
├── state-bootstrap/   GCS state bucket. Local state, no backend block (same as AWS).
├── organization/      Composition root: projects + api enablement.
└── budget/            Billing budget + notification channels.
```

Root configs follow the current repo convention: `main.tf`, `variables.tf` (typed, no
defaults), `terraform.tfvars` (values), `providers.tf` (required_providers + provider),
`terraform.tf` (required_version + backend), `output.tf`.

## Running it

```
terraform -chdir=provider/gcp/organizations/orobo-tech/state-bootstrap init
terraform -chdir=provider/gcp/organizations/orobo-tech/state-bootstrap apply

terraform -chdir=provider/gcp/organizations/orobo-tech/organization init
terraform -chdir=provider/gcp/organizations/orobo-tech/organization plan

terraform -chdir=provider/gcp/organizations/orobo-tech/budget init
terraform -chdir=provider/gcp/organizations/orobo-tech/budget plan
```

`state-bootstrap` runs first: the other two use its bucket as their `gcs` backend.

## Known gotchas

- `google_billing_budget` requires the Terraform-executing principal to have
  `roles/billing.admin` on the billing account — project-level IAM is not enough.
- Project IDs are globally unique and unusable for ~30 days after deletion — confirm
  `orobo-prod` / `orobo-staging` / `orobo-shared` aren't already taken before first
  apply; agree a fallback naming convention now if so. The ids are derived as
  `format("%s-%s", var.app, env)`, so a fallback is a one-line `app` change in
  `organization/terraform.tfvars`.
- `disable_on_destroy = false` on API-enablement resources, so `terraform destroy`
  doesn't error trying to disable APIs on a project that's also being destroyed in
  the same run.
- `deletion_policy` defaults to `PREVENT` on the project module. Flip it to `DELETE`
  in `terraform.tfvars` before any teardown, or the destroy fails.
- Console UI note (already resolved, FYI): project Labels live at
  console.cloud.google.com/projectselector/iam-admin/labels, not under
  IAM & Admin → Settings — that page now shows Tags (a different, IAM-conditions
  feature) instead. Doesn't affect Terraform, only relevant when verifying manually.

## Open blocker

`gcloud billing accounts list` returns 0 items under the current identity — no
billing account visibility at all, not just a missing IAM grant on one that's
visible. This blocks:

- Linking projects to billing
- Applying the budget root (needs `billing.admin` / the account ID itself)

Still needs: identifying who redeemed/owns the GCP credits (check inbox for the
original credits confirmation email, or ask whoever set up org 482771888266), then
either switching to that Google identity or getting `roles/billing.projectManager`
(or `billing.admin`, if also applying the budget) granted on the real billing
account ID.

This does not block the Terraform itself. `billing_account` is empty in both
`terraform.tfvars` files and the project module emits `null` for it, so the projects
can be created unlinked now and linked later by filling that one value in.

## Reference values

- Org ID: `482771888266`
- Projects: `orobo-prod`, `orobo-staging`, `orobo-shared`
- Labels: `env` (prod/staging/shared), `app: orobo`
- Budget thresholds: 50% / 80% / 100%
