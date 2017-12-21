#!/bin/sh
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#
export PATH=$GOPATH/src/github.com/hyperledger/fabric/build/bin:${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=${PWD}

. ./.env_base

if [ -f ./.env ]; then
  . ./.env
fi

# remove previous crypto material and config transactions
if [ ! -d ./config ]; then 
  mkdir ./config
fi


echo "===> Generating crypto material"
# generate crypto material
cryptogen generate --config=./crypto-config.yaml
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

echo "===> Generating Fabric configuration."
echo "-----> Generating genesis block."
# generate genesis block for orderer
#configtxgen -profile ThreeOrgOrdererGenesis -outputBlock ./config/genesis.block
. ./lib/generate_genesis.sh
if [ "$?" -ne 0 ]; then
  echo "Failed to generate orderer genesis block..."
  exit 1
fi

echo "-----> Generating channel confiruation for '$CHANNEL_12'."
# generate CHANNEL_12 configuration transaction
configtxgen -profile Channel-12 -outputCreateChannelTx ./config/$CHANNEL_12.tx -channelID $CHANNEL_12
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

echo "-----> Generating anchor peers configuration for '$CHANNEL_12'."
# generate anchor peer transaction
configtxgen -profile Channel-12 -outputAnchorPeersUpdate ./config/Brand1MSPanchors_$CHANNEL_12.tx -channelID $CHANNEL_12 -asOrg Brand1
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Brand1MSP..."
  exit 1
fi


echo "-----> Generating channel confiruation for '$CHANNEL_23'."
# generate CHANNEL_12 configuration transaction
configtxgen -profile Channel-23 -outputCreateChannelTx ./config/$CHANNEL_23.tx -channelID $CHANNEL_23
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

echo "-----> Generating anchor peers configuration for '$CHANNEL_23'."
# generate anchor peer transaction
configtxgen -profile Channel-23 -outputAnchorPeersUpdate ./config/Brand2MSPanchors_$CHANNEL_23.tx -channelID $CHANNEL_23 -asOrg Brand2
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Brand1MSP..."
  exit 1
fi


echo "-----> Updating docker environment."
CA_CRYPTO_DIR=./crypto-config/peerOrganizations/brand1.com/ca
CA_ORG1_PRIVATE_KEY=$(ls -f1 ./crypto-config/peerOrganizations/brand1.com/ca | grep _sk)
CA_ORG2_PRIVATE_KEY=$(ls -f1 ./crypto-config/peerOrganizations/brand2.com/ca | grep _sk)
CA_ORG4_PRIVATE_KEY=$(ls -f1 ./crypto-config/peerOrganizations/org4.example.com/ca | grep _sk)
CA_ORG5_PRIVATE_KEY=$(ls -f1 ./crypto-config/peerOrganizations/org5.example.com/ca | grep _sk)

# keep original env file
#if [ ! -e  ./.env_orig ]; then
 # cp .env .env_orig
#fi 

cp ./.env_base ./.env
echo CA_ORG1_PRIVATE_KEY=${CA_ORG1_PRIVATE_KEY} >> ./.env
echo CA_ORG2_PRIVATE_KEY=${CA_ORG2_PRIVATE_KEY} >> ./.env
echo CA_ORG3_PRIVATE_KEY=${CA_ORG3_PRIVATE_KEY} >> ./.env
echo CA_ORG4_PRIVATE_KEY=${CA_ORG4_PRIVATE_KEY} >> ./.env
echo CA_ORG5_PRIVATE_KEY=${CA_ORG5_PRIVATE_KEY} >> ./.env

echo "===> Fabric configuraiton is genereated."