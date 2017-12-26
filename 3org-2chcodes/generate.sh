#!/bin/bash -e
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
else
  . ./.env_base
fi

# remove previous crypto material and config transactions
if [ ! -d ./config ]; then
  mkdir ./config
fi


. ./lib/crypto_gen.sh
. ./lib/set_env.sh


echo "${reset}===> Generating Fabric configuration.${reset}"
echo "${msg_sub}-----> Generating genesis block.${reset}"
# generate genesis block for orderer
#configtxgen -profile ThreeOrgOrdererGenesis -outputBlock ./config/genesis.block
. ./lib/generate_genesis.sh
if [ "$?" -ne 0 ]; then
  echo "${err}Failed to generate orderer genesis block...${reset}"
  exit 1
fi

echo "-----> Generating channel confiruation for '$CHANNEL_1'.${reset}"
# generate CHANNEL_1 configuration transaction
configtxgen -profile Channel-1 -outputCreateChannelTx ./config/$CHANNEL_1.tx -channelID $CHANNEL_1
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

echo "-----> Generating anchor peers configuration for '$CHANNEL_1'.${reset}"
# generate anchor peer transaction
configtxgen -profile Channel-1 -outputAnchorPeersUpdate ./config/Brand1MSPanchors_$CHANNEL_1.tx -channelID $CHANNEL_1 -asOrg Brand1
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Brand1MSP..."
  exit 1
fi


echo "-----> Generating channel confiruation for '$CHANNEL_2'.${reset}"
# generate CHANNEL_1 configuration transaction
configtxgen -profile Channel-2 -outputCreateChannelTx ./config/$CHANNEL_2.tx -channelID $CHANNEL_2
if [ "$?" -ne 0 ]; then
  echo "Failed to generate channel configuration transaction..."
  exit 1
fi

echo "-----> Generating anchor peers configuration for '$CHANNEL_2'.${reset}"
# generate anchor peer transaction
configtxgen -profile Channel-2 -outputAnchorPeersUpdate ./config/Brand2MSPanchors_$CHANNEL_2.tx -channelID $CHANNEL_2 -asOrg Brand2
if [ "$?" -ne 0 ]; then
  echo "Failed to generate anchor peer update for Brand1MSP...${reset}"
  exit 1
fi




echo "${msg}===> Fabric configuraiton is genereated.${reset}"
