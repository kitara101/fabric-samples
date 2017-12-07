#!/bin/bash -e

. ./.env

ORG=Org1
echo "===> Creating channels."
. ./lib/create_channel.sh $CHANNEL_12 $ORG

echo "===> $ORG -> join channels" 
. ./lib/join_channel.sh $CHANNEL_12 $ORG 

echo "===> $ORG -> deploy '$CHAINCODE' chaincode"
# deploy chaincode on peer
. ./lib/deploy_chaincode.sh $CHAINCODE $ORG  
# attach to channel
. ./lib/instantiate_chaincode.sh $CHAINCODE $CHANNEL_12 $ORG 
# populate with initial data
. ./lib/init_chaincode.sh $CHAINCODE $CHANNEL_12 $ORG  e

exit

echo "===> $ORG -> deploy '$CHAINCODE' chaincode"

ORG=Org2
echo "===> Creating channels."
. ./lib/create_channel.sh $CHANNEL_12 $ORG
echo "===> $ORG -> join channels" 
. ./lib/join_channel.sh $CHANNEL_23 $ORG 
#. ./lib/instantiate_chaincode.sh $CHAINCODE $CHANNEL_23 $ORG 

echo "===> $ORG -> join channels" 
. ./lib/join_channel.sh $CHANNEL_12 $ORG 
. ./lib/join_channel.sh $CHANNEL_23 $ORG 
echo "===> $ORG -> deploy '$CHAINCODE' chaincode"
# deploy chaincode to peer. No need to instantiate already
. ./lib/deploy_chaincode.sh $CHAINCODE $ORG
#. ./lib/instantiate_chaincode.sh $CHAINCODE $CHANNEL_12 $ORG
echo "===> Chaincode is ready."

