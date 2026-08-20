#!/bin/bash
set -euo pipefail

echo """
################################################
##  Destroying AI Adoption & Feedback Tracker ##
################################################
"""

terraform -chdir=$PWD/adoption-tracker destroy \
  -lock=false -compact-warnings \
  -var-file=$PWD/terraform.tfvars \
  -var-file=$PWD/adoption-tracker/terraform.tfvars
