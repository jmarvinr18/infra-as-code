#!/bin/bash


echo "####################################"
echo "##   CLEAN UP DOCKER CONTAINER    ##"
echo "####################################"
docker stop $(docker ps -a -q --filter="name=$1") || true echo > /dev/null
docker rm $(docker ps -a -q --filter="name=$1") || true echo > /dev/null
docker rmi -f $(docker images -q $2) || true echo > /dev/null

echo "####################################"
echo "##             END                ##"
echo "####################################"