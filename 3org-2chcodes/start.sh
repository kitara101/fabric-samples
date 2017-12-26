#!/bin/bash -e


if [ ! -z "$1" -a "$1" != "clean" ]; then
    echo uknown command line parameter, did you mean \'clean\'?
    exit 1
fi

# stop or stop and clean depening on parameter
if [ "$1" = "clean" ]; then
    echo "${warn}===> Clean run is requested. Cleaning previous configuration.${reset}"
    ./teardown.sh
    ./generate.sh
else
    ./stop.sh
fi



###################################################################################################
###################################################################################################
### Starting hyperledger network containers.
if [ ! -e $DOCKER_CONFIG_FILE ]; then
    echo "${error}===> !!! Docker configuration is not found -> generating whole configuration.${reset}"
    ./teardown.sh
    ./generate.sh
fi

. ./.env

echo "${msg}===> Starting docker conainers.${reset}"
#ca.brand1.com orderer.example.com
docker-compose up -d
#ca.brand1.com ca.brand2.com ca.org3.example.com orderer.example.com peer0.brand1.com peer0.brand2.com brand1.couchdb brand2.couchdb
echo "${msg}===> Containers up.${reset}"
# wait for Hyperledger Fabric to start
echo "${msg}===> Waiting ${FABRIC_START_TIMEOUT} seconds for Fabric to start.${reset}"
sleep ${FABRIC_START_TIMEOUT}

# stop or stop and clean depening on parameter
if [ "$1" = "clean" ]; then
    echo "--> Running CLI container."
    docker-compose -f ./docker-compose.yml up -d cli
    ./deploy.sh
fi
