#!/bin/bash -e
# read some settings
set -e
. ./.env

if [ ! -z "$1" -a "$1" != "clean" ]; then
    echo uknown command line parameter, did you mean \'clean\'?
    exit 1
fi 

# stop or stop and clean depening on parameter
if [ "$1" = "clean" ]; then
    echo "===> Clean run is requested. Cleaning previous configuration."
    ./teardown.sh
    ./generate.sh
else 
    ./stop.sh
fi  

###################################################################################################
###################################################################################################
### Starting hyperledger network containers.
if [ ! -e $DOCKER_CONFIG_FILE ]; then
    echo "===> !!! Docker configuration is not found -> generating whole configuration. "
    ./teardown.sh
    ./generate.sh
fi
echo "===> Starting docker conainers."
#ca.org1.example.com orderer.example.com
docker-compose -f $DOCKER_CONFIG_FILE up -d ca.org1.example.com orderer.example.com peer0.org1.example.com couchdb
echo "===> Containers up."
# wait for Hyperledger Fabric to start
echo "===> Waiting ${FABRIC_START_TIMEOUT} seconds for Fabric to start."
sleep ${FABRIC_START_TIMEOUT}

# stop or stop and clean depening on parameter
if [ "$1" = "clean" ]; then
    ./deploy.sh Org1
fi 



