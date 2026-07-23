#!/bin/bash

AWS_PROFILE="xctuality"

AWS_REGION="ap-southeast-1"

TARGET_GROUP_NAME=$(echo "$1" | jq -r '.name')

EXISTING_TG=$(aws --profile $AWS_PROFILE --region $AWS_REGION elbv2 describe-target-groups \
 --query "TargetGroups[?TargetGroupName=='$TARGET_GROUP_NAME')].TargetGroupArn" \
 --output text)

if [ -n "$EXISTING_TG"]; then
    echo "{\"exists\":\"true\"}"
else 
    echo "{\"exists\":\"false\"}"
fi


aws --profile xctuality --region ap-southeast-1 elbv2 describe-target-groups --query "TargetGroups[?TargetGroupName=='DINGDONG-TG'].TargetGroupArn"