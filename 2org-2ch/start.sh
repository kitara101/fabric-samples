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
echo "===> Starting docker conainers."
docker-compose -f $DOCKER_CONFIG_FILE up -d ca.example.com orderer.example.com peer0.org1.example.com couchdb
echo "===> Containers up."
# wait for Hyperledger Fabric to start
echo "===> Waiting ${FABRIC_START_TIMEOUT} seconds for Fabric to start."
sleep ${FABRIC_START_TIMEOUT}

# stop or stop and clean depening on parameter
if [ "$1" != "clean" ]; then
    exit
fi 

###################################################
# Create the channels
###################################################
### Channel A
echo "===> Creating channel '$CHANNEL_A'."
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel create -o orderer.example.com:7050 -c $CHANNEL_A -f /etc/hyperledger/configtx/$CHANNEL_A.tx
# Join peer0.org1.example.com to the channel.
echo "===> Joining channel '$CHANNEL'."
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel join -b $CHANNEL_A.block
###################################################
### Channel A
echo "===> Creating channel '$CHANNEL_B'."
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel create -o orderer.example.com:7050 -c $CHANNEL_B -f /etc/hyperledger/configtx/$CHANNEL_B.tx
# Join peer0.org1.example.com to the channel.
echo "===> Joining channel '$CHANNEL_B'."
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@org1.example.com/msp" peer0.org1.example.com peer channel join -b $CHANNEL_B.block

###################################################
# Deploy the chaincode
###################################################

echo "===> Installing chaincode application (Smart Contract)."
echo "--> Running CLI container."
docker-compose -f ./docker-compose.yml up -d cli

# deploy to channel_a
echo "--> Deploying chaincode '$CHAINCODE' to peer."
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode install -n $CHAINCODE -v 1.0 -p github.com/fabcar
echo "--> Initiating chaincode '$CHAINCODE' on channel '$CHANNEL_A'."
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode instantiate -o orderer.example.com:7050 -C $CHANNEL_A -n $CHAINCODE -v 1.0 -c '{"Args":[""]}' -P "OR ('Org1MSP.member','Org2MSP.member')"

echo "===> Waiting ${FABRIC_START_TIMEOUT} seconds for chaincode container to start."
sleep ${FABRIC_START_TIMEOUT}

echo "--> Invoking chaincode on channel '$CHANNEL_A' to init it on the peer."
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_A -n $CHAINCODE -c '{"function":"initLedger","Args":[""]}'
echo "===> Chaincode is ready."

# deploy to channel_b
echo "--> Initiating chaincode '$CHAINCODE' on channel '$CHANNEL_A'."
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode instantiate -o orderer.example.com:7050 -C $CHANNEL_B -n $CHAINCODE -v 1.0 -c '{"Args":[""]}' -P "OR ('Org1MSP.member','Org2MSP.member')"

echo "===> Waiting ${FABRIC_START_TIMEOUT} seconds for chaincode container to start."
sleep ${FABRIC_START_TIMEOUT}

echo "--> Invoking chaincode on channel '$CHANNEL_B' to init it on the peer."
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_B -n $CHAINCODE -c '{"function":"initLedger","Args":[""]}'
echo "===> Chaincode is ready."

