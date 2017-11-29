#!/bin/sh
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}
. ./.env

# remove previous crypto material and config transactions
rm -fr config/*
#rm -fr crypto-config/*

echo "===> Generating crypto material"

# generate crypto material
cryptogen generate --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

echo "===> Generating Fabric configuration."
echo "--> Generating genesis block."
# generate genesis block for orderer
configtxgen -profile OneOrgOrdererGenesis -outputBlock ./config/genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

echo "--> Generating channel confiruation for '$CHANNEL_A'."
# generate CHANNEL_A configuration transaction
configtxgen -profile OneOrgChannel -outputCreateChannelTx ./config/$CHANNEL_A.tx -channelID $CHANNEL_A
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

echo "--> Generating anchor peers configuration for '$CHANNEL_A'."
# generate anchor peer transaction
configtxgen -profile OneOrgChannel -outputAnchorPeersUpdate ./config/Org1MSPanchors_$CHANNEL_A.tx -channelID $CHANNEL_A -asOrg Org1MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi


echo "--> Generating channel confiruation for '$CHANNEL_B'."
# generate CHANNEL_A configuration transaction
configtxgen -profile OneOrgChannel -outputCreateChannelTx ./config/$CHANNEL_B.tx -channelID $CHANNEL_B
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

echo "--> Generating anchor peers configuration for '$CHANNEL_B'."
# generate anchor peer transaction
configtxgen -profile OneOrgChannel -outputAnchorPeersUpdate ./config/Org1MSPanchors_$CHANNEL_B.tx -channelID $CHANNEL_B -asOrg Org1MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi


echo "--> Generating docker container configuration."
CA_CRYPTO_DIR=./crypto-config/peerOrganizations/org1.example.com/ca
CA_PRIVATE_KEY=$(ls -f1 ./crypto-config/peerOrganizations/org1.example.com/ca | grep _sk)
sed -e "s/{CA_PRIVATE_KEY}/${CA_PRIVATE_KEY}/" ./docker-compose-template.yml > $DOCKER_CONFIG_FILE

echo "===> Fabric configuraiton is genereated."