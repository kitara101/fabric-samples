#!/bin/bash -e
# Shut down the Docker containers that might be currently running.


CONTAINERS=$(docker ps -q)
if [ -n "$CONTAINERS" ]; then
    echo "${msg}===> Stopping docker containers.${reset}"
    docker-compose stop
    echo "${msg}===> Stopped.${reset}"
fi
