#!/bin/bash

FABRIC_CFG_PATH=. configtxgen -channelID channel-1 -inspectBlock ./config/genesis.block -profile ThreeOrgOrdererGenesis > ./config/genesis.config
FABRIC_CFG_PATH=. configtxgen -channelID channel-1 -inspectChannelCreateTx ./config/channel-1.tx -profile ThreeOrgOrdererGenesis > ./config/channel-1.config

