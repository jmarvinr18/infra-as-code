#!/bin/bash

echo """
######################################
##  Provisioning VPC Infrastructure ##
######################################
""" 
terraform -chdir=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/organizations/krunchie-kreates/accounts/donato-and-zarate/production/vpc-network init


terraform -chdir=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/organizations/krunchie-kreates/accounts/donato-and-zarate/production/vpc-network apply -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/organizations/krunchie-kreates/accounts/donato-and-zarate/production/terraform.tfvars -compact-warnings


echo """
################################
##  Provisioning Budget Setup ##
################################
""" 
terraform -chdir=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/organizations/krunchie-kreates/accounts/donato-and-zarate/production/budget init

terraform -chdir=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/organizations/krunchie-kreates/accounts/donato-and-zarate/production/budget apply -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/organizations/krunchie-kreates/accounts/donato-and-zarate/production/terraform.tfvars -compact-warnings
