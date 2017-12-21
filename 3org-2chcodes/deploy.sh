#!/bin/bash -e

. .env
echo deploying...
. ./lib/deploy_consorcium.sh Default $CHAINCODE $CHANNEL_1 TLabel Brand1 Distibutor-1 Distibutor-2 Distibutor-3  
#. ./lib/deploy_consorcium.sh Consorcium-23 $CHAINCODE $CHANNEL_23 Org2 Org3
