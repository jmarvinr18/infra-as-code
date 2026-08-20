#!/bin/bash
set -euo pipefail

echo """
##################################################
##  Provisioning AI Adoption & Feedback Tracker ##
##################################################
"""

terraform -chdir=$PWD/adoption-tracker init
terraform -chdir=$PWD/adoption-tracker apply -auto-approve=true \
  -lock=false -compact-warnings \
  -var-file=$PWD/terraform.tfvars \
  -var-file=$PWD/adoption-tracker/terraform.tfvars

echo """
############################
##  Applying the schema   ##
############################
"""

# The migration is idempotent, so this runs on every apply rather than only the
# first. That is what keeps a schema change from needing a separate, forgettable
# step — and what stops the first curl of the day hitting a table that is not
# there yet.
$PWD/adoption-tracker/bootstrap-schema.sh

echo """
############################
##  Endpoints             ##
############################
"""

terraform -chdir=$PWD/adoption-tracker output
