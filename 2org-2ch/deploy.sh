#!/bin/bash -e

. ./.env
ORG=$1
echo "Org = $1"


###################################################
# Create the channels
###################################################
### Channel A
echo "===> Creating channel '$CHANNEL_A'."
docker exec -e "CORE_PEER_LOCALMSPID=${ORG}MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@${ORG,}.example.com/msp" peer0.${ORG,}.example.com peer channel create -o orderer.example.com:7050 -c $CHANNEL_A -f /etc/hyperledger/configtx/$CHANNEL_A.tx
# Join peer0.${ORG,}.example.com to the channel.
echo "===> Joining channel '$CHANNEL_A'."
docker exec -e "CORE_PEER_LOCALMSPID=${ORG}MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@${ORG,}.example.com/msp" peer0.${ORG,}.example.com peer channel join -b $CHANNEL_A.block
###################################################
### Channel A
echo "===> Creating channel '$CHANNEL_B'."
docker exec -e "CORE_PEER_LOCALMSPID=${ORG}MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@${ORG,}.example.com/msp" peer0.${ORG,}.example.com peer channel create -o orderer.example.com:7050 -c $CHANNEL_B -f /etc/hyperledger/configtx/$CHANNEL_B.tx
# Join peer0.${ORG,}.example.com to the channel.
echo "===> Joining channel '$CHANNEL_B'."
docker exec -e "CORE_PEER_LOCALMSPID=${ORG}MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@${ORG,}.example.com/msp" peer0.${ORG,}.example.com peer channel join -b $CHANNEL_B.block

###################################################
# Deploy the chaincode
###################################################

echo "===> Installing chaincode application (Smart Contract)."
echo "--> Running CLI container."
docker-compose -f ./docker-compose.yml up -d cli

# deploy to channel_a
echo "--> Deploying chaincode '$CHAINCODE' to peer."
docker exec -e "CORE_PEER_LOCALMSPID=${ORG}MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${ORG,}.example.com/users/Admin@${ORG,}.example.com/msp" cli peer chaincode install -n $CHAINCODE -v 1.0 -p github.com/fabcar
echo "--> Initiating chaincode '$CHAINCODE' on channel '$CHANNEL_A'."
docker exec -e "CORE_PEER_LOCALMSPID=${ORG}MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${ORG,}.example.com/users/Admin@${ORG,}.example.com/msp" cli peer chaincode instantiate -o orderer.example.com:7050 -C $CHANNEL_A -n $CHAINCODE -v 1.0 -c '{"Args":[""]}' -P "OR ('${ORG}MSP.member','Org2MSP.member')"

echo "===> Waiting ${FABRIC_START_TIMEOUT} seconds for chaincode container to start."
sleep ${FABRIC_START_TIMEOUT}

echo "--> Invoking chaincode on channel '$CHANNEL_A' to init it on the peer."
docker exec -e "CORE_PEER_LOCALMSPID=${ORG}MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${ORG,}.example.com/users/Admin@${ORG,}.example.com/msp" cli peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_A -n $CHAINCODE -c '{"function":"initLedger","Args":[""]}'
echo "===> Chaincode is ready."

# deploy to channel_b
echo "--> Initiating chaincode '$CHAINCODE' on channel '$CHANNEL_A'."
docker exec -e "CORE_PEER_LOCALMSPID=${ORG}MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${ORG,}.example.com/users/Admin@${ORG,}.example.com/msp" cli peer chaincode instantiate -o orderer.example.com:7050 -C $CHANNEL_B -n $CHAINCODE -v 1.0 -c '{"Args":[""]}' -P "OR ('${ORG}MSP.member','Org2MSP.member')"

echo "===> Waiting ${FABRIC_START_TIMEOUT} seconds for chaincode container to start."
sleep ${FABRIC_START_TIMEOUT}

echo "--> Invoking chaincode on channel '$CHANNEL_B' to init it on the peer."
docker exec -e "CORE_PEER_LOCALMSPID=${ORG}MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${ORG,}.example.com/users/Admin@${ORG,}.example.com/msp" cli peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL_B -n $CHAINCODE -c '{"function":"initLedger","Args":[""]}'
echo "===> Chaincode is ready."