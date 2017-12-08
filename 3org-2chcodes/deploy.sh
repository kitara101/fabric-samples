#!/bin/bash -e

. .env

. ./lib/deploy_consorcium.sh Consorcium-12 $CHAINCODE $CHANNEL_12 Org1 Org2
. ./lib/deploy_consorcium.sh Consorcium-23 $CHAINCODE $CHANNEL_23 Org2 Org3
