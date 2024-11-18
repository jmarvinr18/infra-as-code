#!/bin/bash

ingress_name=$1
namespace=$2

# Get the CNAME value of the ingress
cname=$(kubectl get ingress $ingress_name -n $namespace -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

echo "$cname"

