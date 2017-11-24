#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -e

# Shut down the Docker containers for the system tests.
docker-compose -f docker-compose.yml kill && docker-compose -f docker-compose.yml down

# remove the local state
rm -f ~/.hfc-key-store/*

echo removing docker containers
CONTAINERS=$(docker ps -aqf name=dev)
if [ -n "$CONTAINERS" ]; then
    docker rm -v $CONTAINERS
fi

echo removing docker images
# remove chaincode docker images
IMAGES=$(docker images dev-* -q)
if [ -n "$IMAGES" ]; then
    docker rmi $IMAGES
fi

# Your system is now clean
