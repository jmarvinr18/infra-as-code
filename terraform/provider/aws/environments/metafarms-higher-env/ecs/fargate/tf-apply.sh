#!/bin/bash

terraform -chdir=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/1-Role apply -auto-approve -lock=false
terraform -chdir=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/2-Cluster apply -auto-approve -lock=false
terraform -chdir=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/3-TaskDefinition apply -auto-approve -lock=false
terraform -chdir=/mnt/d/Users/RouVin/Documents/xctuality/devops/infra-as-code/terraform/provider/aws/environments/metafarms-higher-env/ecs/fargate/4-Service apply -auto-approve -lock=false
