#!/bin/bash


echo """
##########################
##  Destroying Service  ##
##########################
""" 
terraform -chdir=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/4-Service destroy -auto-approve -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/terraform.tfvars



echo """
###################################
##  Destroying Task Definitions  ##
###################################
""" 


terraform -chdir=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/3-TaskDefinition destroy -auto-approve -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/terraform.tfvars



echo """
##########################
##  Destroying Cluster  ##
##########################
""" 


terraform -chdir=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/2-Cluster destroy -auto-approve -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/terraform.tfvars

echo """
############################
##  Destroying ECS Roles  ##
############################
""" 

terraform -chdir=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/1-Role destroy -auto-approve -lock=false -var-file=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/terraform.tfvars