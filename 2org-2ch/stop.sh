#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error, print all commands.
set -e

# Shut down the Docker containers that might be currently running.

CONTAINERS=$(docker ps -q)
if [ -n "$CONTAINERS" ]; then
    echo "===> Stopping docker containers."
    docker-compose -f docker-compose.yml stop
    echo "===> Stopped."
fi
