#!/bin/bash

echo """
############################
##  Destroying EKS RBAC ##
############################
""" 
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/6-RBAC destroy -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/xctuality-higher-env/eks-v2/terraform.tfvars -compact-warnings


echo """
############################
##  Destroying EKS Helm ##
############################
""" 
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/5-Helm destroy -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/xctuality-higher-env/eks-v2/terraform.tfvars -compact-warnings


echo """
############################
##  Destroying EKS Nodes ##
############################
""" 
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/4-Node destroy -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/xctuality-higher-env/eks-v2/terraform.tfvars -compact-warnings



echo """
############################
##  Destroying EKS Clusters ##
############################
""" 


terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/3-Cluster destroy -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/xctuality-higher-env/eks-v2/terraform.tfvars -compact-warnings



echo """
############################
##  Destroying EKS Network ##
############################
""" 
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/2-Network destroy -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/xctuality-higher-env/eks-v2/terraform.tfvars -compact-warnings



echo """
#############################
##  Destroying EKS Roles ##
#############################
""" 
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/1-Role destroy -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/xctuality-higher-env/eks-v2/terraform.tfvars -compact-warnings

