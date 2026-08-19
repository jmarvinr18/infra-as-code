
org_id = "482771888266"
app    = "orobo"
envs   = ["prod", "staging", "shared"]

purpose = "apps"
region  = "asia-southeast1"

# Empty until a billing account is visible to the terraform identity.
# See NOTES.md, "Open blocker".
billing_account = ""

# Flip to DELETE before ever tearing these projects down.
deletion_policy = "PREVENT"

services = [
  "cloudresourcemanager.googleapis.com",
  "cloudbilling.googleapis.com",
  "billingbudgets.googleapis.com",
  "iam.googleapis.com",
  "compute.googleapis.com",
  "storage.googleapis.com",
  "monitoring.googleapis.com",
  "logging.googleapis.com"
]
