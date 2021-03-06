#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
# Exit on first error
set -e

# don't rewrite paths for Windows Git Bash users
export MSYS_NO_PATHCONV=1

starttime=$(date +%s)

# launch network; create channel and join peer to channel
cd ../basic-network
./start.sh
. ./.env

# Now launch the CLI container in order to install, instantiate chaincode
# and prime the ledger with our 10 cars
echo "===> Running CLI containers."
docker-compose -f ./docker-compose.yml up -d cli

echo "===> Installing chaincode application (Smart Contract)."
#CHANNEL=mychannel
CHAINCODE=fabcar
echo "--> Deploying chaincode '$CHAINCODE' to channel '$CHANNEL'."
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode install -n $CHAINCODE -v 1.0 -p github.com/fabcar
echo "--> Initiating chaincode."
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode instantiate -o orderer.example.com:7050 -C $CHANNEL -n $CHAINCODE -v 1.0 -c '{"Args":[""]}' -P "OR ('Org1MSP.member','Org2MSP.member')"

FABRIC_START_TIMEOUT=10
echo "===> Waiting ${FABRIC_START_TIMEOUT} seconds before proceeding."
sleep ${FABRIC_START_TIMEOUT}

echo "--> Invoking chaincode to actually run it on the peer."
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL -n $CHAINCODE -c '{"function":"initLedger","Args":[""]}'
echo "===> Chaincode is ready."

printf "\nTotal setup execution time : $(($(date +%s) - starttime)) secs ...\n\n\n"
printf "Start by installing required packages run 'npm install'\n"
printf "Then run 'node enrollAdmin.js', then 'node registerUser'\n\n"
printf "The 'node invoke.js' will fail until it has been updated with valid arguments\n"
printf "The 'node query.js' may be run at anytime once the user has been registered\n\n"
