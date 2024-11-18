#!/bin/bash

ingress_name=$1
namespace=$2

# Get the address value of the ingress
address=$(kubectl get ingress $ingress_name -n $namespace -o wide | awk 'NR>1 {print $4}')

echo "$address"
