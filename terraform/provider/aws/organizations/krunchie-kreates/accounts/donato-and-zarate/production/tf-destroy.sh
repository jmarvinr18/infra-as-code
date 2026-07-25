#!/bin/bash

echo """
######################################
##  Destroying VPC Infrastructure   ##
######################################
""" 
terraform -chdir=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/organizations/krunchie-kreates/accounts/donato-and-zarate/production/vpc-network destroy -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/organizations/krunchie-kreates/accounts/donato-and-zarate/production/terraform.tfvars -compact-warnings

echo """
#######################################
##  Destroying Budget Setup          ##
#######################################
""" 

terraform -chdir=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/organizations/krunchie-kreates/accounts/donato-and-zarate/production/budget destroy -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/organizations/krunchie-kreates/accounts/donato-and-zarate/production/terraform.tfvars -compact-warnings
