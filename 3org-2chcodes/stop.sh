#!/bin/bash -e
# Shut down the Docker containers that might be currently running.

CONTAINERS=$(docker ps -q)
if [ -n "$CONTAINERS" ]; then
    echo "===> Stopping docker containers."
    docker-compose stop
    echo "===> Stopped."
fi
