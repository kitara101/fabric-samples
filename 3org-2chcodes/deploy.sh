#!/bin/bash -e

. .env

. ./lib/deploy_consorcium.sh Consorcium-12 $CHAINCODE $CHANNEL_12 Brand1 Brand2 
#. ./lib/deploy_consorcium.sh Consorcium-23 $CHAINCODE $CHANNEL_23 Brand2 Org3
