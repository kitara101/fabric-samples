#!/bin/bash -e

. .env

. ./lib/deploy_consorcium.sh Consorcium-12 $CHAINCODE $CHANNEL_1 Brand1 TraceLabel   
. ./lib/deploy_consorcium.sh Consorcium-23 $CHAINCODE $CHANNEL_2 Brand2 TraceLabel
