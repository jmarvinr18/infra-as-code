#!/bin/bash

echo """
#############################
##  Provisioning ECS Roles ##
#############################
""" 
terraform -chdir=terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/1-Role apply -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/terraform.tfvars -compact-warnings


echo """
############################
##  Provisioning Clusters ##
############################
""" 
terraform -chdir=terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/2-Cluster apply -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/terraform.tfvars -compact-warnings


echo """
####################################
##  Provisioning Task Definitions ##
####################################
""" 

terraform -chdir=terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/3-TaskDefinition apply -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/terraform.tfvars -compact-warnings



echo """
############################
##  Provisioning Service  ##
############################
""" 
terraform -chdir=terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/4-Service apply -auto-approve=true -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/terraform.tfvars -compact-warnings
