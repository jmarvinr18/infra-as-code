# ─────────────────────────────────────────────────────────────────────────────
# Account-level values, shared by every component under production/.
# Passed with -var-file by tf-apply.sh, alongside each component's own tfvars.
# ─────────────────────────────────────────────────────────────────────────────

client      = "sunvibe-agentverse"
environment = "production"
region      = "ap-southeast-1"

# TODO: the member account id. Fill this in before the first apply — the
# provider assumes OrganizationAccountAccessRole in it, and every apply fails
# until it is right.
client_account_id = "000000000000"
