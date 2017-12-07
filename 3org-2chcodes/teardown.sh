#!/bin/bash -e

./stop.sh

# Shut down the Docker containers for the system tests.
echo "===> Removing docker containers."
echo "--> Removing main containers."
docker-compose down -v --remove-orphans

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
