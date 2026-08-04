#!/bin/bash

echo """
######################################
##  Provisioning VPC Infrastructure ##
######################################
""" 
terraform -chdir=$PWD/vpc-network init
terraform -chdir=$PWD/vpc-network apply -auto-approve=true \
-lock=false -var-file=$PWD/terraform.tfvars -compact-warnings


echo """
################################
##  Provisioning Budget Setup ##
################################
""" 
terraform -chdir=$PWD/budget init
terraform -chdir=$PWD/budget apply -auto-approve=true \
-lock=false -var-file=$PWD/terraform.tfvars -compact-warnings
