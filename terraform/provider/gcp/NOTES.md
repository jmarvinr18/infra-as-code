Handoff: GCP project structure & billing budget — context for Claude Code

Paste this as your first message in Claude Code, or save it into the repo (e.g. terraform/provider/gcp/NOTES.md) and tell Claude Code to read it before starting.

Task

Build a new Terraform provider tree for GCP, mirroring the existing AWS one:

terraform/provider/
├── aws/
│   └── modules/          ← existing pattern to mirror
└── gcp/                  ← NEW
    ├── modules/          ← reusable GCP resources, same structure as aws/modules
    └── organizations/
        └── orobo-tech/   ← initial org, root config that consumes the modules

Before writing anything: inspect terraform/provider/aws/modules directly (find, ls, cat a couple of module folders) to confirm the real pattern — naming convention, whether each module is single-resource or grouped, standard files per module (main.tf / variables.tf / outputs.tf / versions.tf / README.md?), how the org-level root wires modules together, remote state / backend config, provider version pinning style. Match that exactly rather than assuming.

What the GCP modules need to cover

Goal: orobo-prod, orobo-staging, orobo-shared projects under one Org/billing account, with billing protected by budget alerts.

Project creation module — creates a GCP project under an Org or Folder, with env and app labels applied at creation (env: prod|staging|shared, app: orobo).
API enablement module — enables a configurable list of APIs on a project (baseline: cloudresourcemanager, cloudbilling, billingbudgets, iam, compute, storage, monitoring, logging).
Billing budget module — one google_billing_budget scoped to the billing account (covering all three projects to start, not split per-project yet), with:
Threshold rules at 50% / 80% / 100%
A google_monitoring_notification_channel (email) wired via all_updates_rule.monitoring_notification_channels
disable_default_iam_recipients = false (keep built-in billing-admin emails active alongside the custom channel)
organizations/orobo-tech root config — the composition root that calls the three modules above for the orobo-tech org, produces outputs for project IDs/numbers and the budget name.

A first-pass (non-repo-matched) version of these four pieces already exists from earlier discussion — reuse the resource logic, just restructure the file/folder layout to match whatever aws/modules actually does.

Known gotchas to carry over
google_billing_budget requires the Terraform-executing principal to have roles/billing.admin on the billing account — project-level IAM is not enough.
Project IDs are globally unique and unusable for ~30 days after deletion — confirm orobo-prod/orobo-staging/orobo-shared aren't already taken before first apply; agree a fallback naming convention now if so.
disable_on_destroy = false on API-enablement resources, so terraform destroy doesn't error trying to disable APIs on a project that's also being destroyed in the same run.
Console UI note (already resolved, just FYI): project Labels live at console.cloud.google.com/projectselector/iam-admin/labels, not under IAM & Admin → Settings — that page now shows Tags (a different, IAM-conditions feature) instead. Doesn't affect Terraform, only relevant if verifying manually in Console.
Open blocker — not yet resolved

gcloud billing accounts list returns 0 items under the current identity — no billing account visibility at all, not just a missing IAM grant on one that's visible. This blocks:

Linking projects to billing
Applying the budget module (needs billing.admin / the account ID itself)

Still needs: identifying who redeemed/owns the GCP credits (check inbox for the original credits confirmation email, or ask whoever set up org 482771888266), then either switching to that Google identity or getting roles/billing.projectManager (or billing.admin, if also applying the budget) granted on the real billing account ID.

This does not block writing the Terraform modules themselves — only the actual apply of billing-account-linked resources. Claude Code can build and plan everything else in parallel.

Reference values
Org ID: 482771888266
Projects: orobo-prod, orobo-staging, orobo-shared
Labels: env (prod/staging/shared), app: orobo
Budget thresholds: 50% / 80% / 100%