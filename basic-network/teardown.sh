#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -e

./stop.sh

# Shut down the Docker containers for the system tests.
echo "===> Removing docker containers."
echo "--> Removing main containers."
docker-compose -f docker-compose.yml down

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
# remove the local state
rm -f ~/.hfc-key-store/*

# Your system is now clean
