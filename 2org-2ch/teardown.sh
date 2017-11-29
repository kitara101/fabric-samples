#!/bin/bash -e
. ./.env
./stop.sh

# Shut down the Docker containers for the system tests.
echo "===> Removing docker containers."
echo "--> Removing main containers."
if [ -e $DOCKER_CONFIG_FILE ]; then 
    docker-compose -f docker-compose.yml down
    rm $DOCKER_CONFIG_FILE
elif [ -n "$(docker ps -q)" ]; then
    docker rm -fv $(docker ps -q)
fi

echo "--> Removing chaincode containers."
CONTAINERS=$(docker ps -aqf name=dev)
if [ -n "$CONTAINERS" ]; then
    docker rm -v $CONTAINERS
fi

# remove chaincode docker images
echo "--> Removing chaincode images."
IMAGES=$(docker images dev-* -q)
if [ -n "$IMAGES" ]; then 
    docker rmi $IMAGES
fi

echo "===> Containers removed."

echo "===> Removing stale crypto material."

# remove the local state
rm -f ~/.hfc-key-store/*
rm -fr ./hfc-key-store
rm -rf ./crypto-config
# Your system is now clean
