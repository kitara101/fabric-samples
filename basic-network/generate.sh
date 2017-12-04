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
#rm -fr config/*
rm -fr crypto-config/*

echo "====> Generating crypto material"

# generate crypto material
cryptogen generate --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

echo "====> Generating Fabric configuration."
echo "--> Generating genesis block."
# generate genesis block for orderer
configtxgen -profile OneOrgOrdererGenesis -outputBlock ./config/genesis.block
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

echo "--> Generating channel confiruation for '$CHANNEL'."
# generate channel configuration transaction
configtxgen -profile OneOrgChannel -outputCreateChannelTx ./config/$CHANNEL.tx -channelID $CHANNEL
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

echo "--> Generating anchor peers configuration for '$CHANNEL'."
# generate anchor peer transaction
configtxgen -profile OneOrgChannel -outputAnchorPeersUpdate ./config/Org1MSPanchors_$CHANNEL.tx -channelID $CHANNEL -asOrg Org1MSP
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Org1MSP..."
  exit 1
fi
echo "====> Fabric configuraiton is genereated."