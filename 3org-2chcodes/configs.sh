#!/bin/bash

FABRIC_CFG_PATH=. configtxgen -channelID channel-12 -inspectBlock ./config/genesis.block -profile ThreeOrgOrdererGenesis > ./config/genesis.config
FABRIC_CFG_PATH=. configtxgen -channelID channel-12 -inspectChannelCreateTx ./config/channel-12.tx -profile ThreeOrgOrdererGenesis > ./config/channel-12.config

