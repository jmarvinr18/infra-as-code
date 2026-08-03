#!/bin/bash

echo """
######################################
##  Destroying VPC Infrastructure   ##
######################################
""" 
terraform -chdir=$PWD/vpc-network init
terraform -chdir=$PWD/vpc-network destroy -auto-approve=true \
-lock=false -var-file=$PWD/terraform.tfvars -compact-warnings

echo """
#######################################
##  Destroying Budget Setup          ##
#######################################
""" 
terraform -chdir=$PWD/vpc-network init
terraform -chdir=$PWD/budget destroy -auto-approve=true \
-lock=false -var-file=$PWD/terraform.tfvars -compact-warnings
