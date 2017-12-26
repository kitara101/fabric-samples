#!/bin/bash -e

. ./.env_base
./stop.sh

# Shut down the Docker containers for the system tests.
echo "${msg}===> Removing docker containers.${reset}"
echo "${msg_sub}-----> Removing main containers.${reset}"
IDS=$(docker ps -aq)
if [ "" != "$IDS" ]; then
  docker rm --force -v $IDS
fi
docker-compose down -v --remove-orphans

echo "${msg_sub}-----> Removing chaincode containers.${reset}"
CONTAINERS=$(docker ps -aqf name=dev)
if [ -n "$CONTAINERS" ]; then
    docker rm -v $CONTAINERS
fi

# remove chaincode docker images
echo "${msg_sub}-----> Removing chaincode images.${reset}"
IMAGES=$(docker images dev-* -q)
if [ -n "$IMAGES" ]; then
    docker rmi $IMAGES
fi

echo "${msg}===> Containers removed.${reset}"

echo "${msg}===> Removing stale crypto material.${reset}"

# remove the local state
rm -f ~/.hfc-key-store/*
rm -fr ./hfc-key-store
rm -rf ./crypto-config
rm -rf ./config

if [ -f .env ]; then
  rm .env
fi
# Your system is now clean
