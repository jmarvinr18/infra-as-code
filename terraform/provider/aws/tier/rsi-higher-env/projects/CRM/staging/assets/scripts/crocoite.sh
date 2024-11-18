#!/bin/bash



echo "####################################"
echo "##   CLEAN UP DOCKER CONTAINER    ##"
echo "####################################"

docker stop $(docker ps -a -q  --filter="name=crocoite-api") || true echo > /dev/null
docker rm $(docker ps -a -q --filter="name=crocoite-api") || true echo > /dev/null
docker rmi -f $(docker images -q aslitechnologies/crocoite) || true echo > /dev/null

echo "####################################"
echo "##             END                ##"
echo "####################################"