#!/bin/bash -e

. ./.env
ORG=$1
echo "Org = $1"


ORG=Org1
echo "===> Creating channels."
. ./lib/create_channel.sh $CHANNEL_A $ORG
. ./lib/create_channel.sh $CHANNEL_B $ORG


echo "===> $ORG -> join channels" 
. ./lib/join_channel.sh $CHANNEL_A $ORG 
. ./lib/join_channel.sh $CHANNEL_B $ORG 

echo "===> $ORG -> deploy '$CHAINCODE' chaincode"
# deploy chaincode on peer
. ./lib/deploy_chaincode.sh $CHAINCODE $ORG  
# attach to channel
. ./lib/instantiate_chaincode.sh $CHAINCODE $CHANNEL_A $ORG 
. ./lib/instantiate_chaincode.sh $CHAINCODE $CHANNEL_B $ORG 
# populate with initial data
. ./lib/init_chaincode.sh $CHAINCODE $CHANNEL_A $ORG 

echo "===> $ORG -> deploy '$CHAINCODE' chaincode"

ORG=Org2
echo "===> $ORG -> join channels" 
. ./lib/join_channel.sh $CHANNEL_A $ORG 
. ./lib/join_channel.sh $CHANNEL_B $ORG 
echo "===> $ORG -> deploy '$CHAINCODE' chaincode"
# deploy chaincode to peer. No need to instantiate already
. ./lib/deploy_chaincode.sh $CHAINCODE $ORG
#. ./lib/instantiate_chaincode.sh $CHAINCODE $CHANNEL_A $ORG
echo "===> Chaincode is ready."

