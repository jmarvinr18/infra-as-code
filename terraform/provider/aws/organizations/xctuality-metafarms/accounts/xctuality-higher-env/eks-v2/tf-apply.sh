#!/bin/bash

echo """
#############################
##  Provisioning EKS Roles ##
#############################
""" 
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/1-Role init
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/1-Role apply -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/xctuality-higher-env/eks-v2/terraform.tfvars -compact-warnings


echo """
###############################
##  Provisioning EKS Network ##
###############################
""" 
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/2-Network init
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/2-Network apply -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/xctuality-higher-env/eks-v2/terraform.tfvars -compact-warnings


echo """
################################
##  Provisioning EKS Clusters ##
################################
""" 
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/3-Cluster init
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/3-Cluster apply -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/xctuality-higher-env/eks-v2/terraform.tfvars -compact-warnings


echo """
############################
##  Provisioning EKS NODE ##
############################
""" 
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/4-Node init
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/4-Node apply -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/xctuality-higher-env/eks-v2/terraform.tfvars -compact-warnings


echo """
##################################
##  Provisioning EKS HELM CHART ##
##################################
""" 
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/5-Helm init
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/5-Helm apply -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/xctuality-higher-env/eks-v2/terraform.tfvars -compact-warnings


echo """
##################################
##  Provisioning EKS RBAC       ##
##################################
""" 
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/6-RBAC init
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/6-RBAC apply -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/xctuality-higher-env/eks-v2/terraform.tfvars -compact-warnings


echo """
##################################
##  Provisioning EKS Add On       ##
##################################
""" 
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/7-AddOn init
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/7-AddOn apply -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/xctuality-higher-env/eks-v2/terraform.tfvars -compact-warnings


echo """
##################################
##  Provisioning EKS EBS CSI    ##
##################################
""" 
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/8-Storage init
terraform -chdir=terraform/provider/aws/environments/xctuality-higher-env/eks-v2/8-Storage apply -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/xctuality-higher-env/eks-v2/terraform.tfvars -compact-warnings




aws eks update-kubeconfig --region ap-southeast-1 --name xct-higher-eks

kubectl apply -f terraform/provider/aws/environments/xctuality-higher-env/eks-v2/k8/roles/admin/admin-cluster-role-binding.yaml
kubectl apply -f terraform/provider/aws/environments/xctuality-higher-env/eks-v2/k8/roles/viewer/viewer-cluster-role-binding.yaml
kubectl apply -f terraform/provider/aws/environments/xctuality-higher-env/eks-v2/k8/roles/viewer/viewer-cluster-role.yaml