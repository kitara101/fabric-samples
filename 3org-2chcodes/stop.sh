#!/bin/bash -e
# Shut down the Docker containers that might be currently running.


CONTAINERS=$(docker ps -q)
if [ -n "$CONTAINERS" ]; then
    echo "${green}===> Stopping docker containers."
    docker-compose stop
    echo "${green}===> Stopped."
fi
