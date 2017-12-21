#!/bin/sh  -e

#cd ./config
CONFIG_PATH=./config

cp $CONFIG_PATH/genesis.block $CONFIG_PATH/genesis.block.orig
#docker exec -e "CORE_PEER_ADDRESS=peer0.brand1.com:7051" -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/brand1.com/users/Admin@brand1.com/msp" cli peer channel fetch config  -c testchainid -0 orderer.example.org

curl -X POST --data-binary @$CONFIG_PATH/genesis.block.orig http://127.0.0.1:7059/protolator/decode/common.Block | \
jq .data.data[0].payload.data.config  > $CONFIG_PATH/config_block_orig.json

#. ./lib/generate_genesis.sh
. ./lib/generate_genesis.sh

mv $CONFIG_PATH/genesis.block $CONFIG_PATH/genesis.block.new
 curl -X POST --data-binary @$CONFIG_PATH/genesis.block.new http://127.0.0.1:7059/protolator/decode/common.Block | \
jq .data.data[0].payload.data.config  > $CONFIG_PATH/config_block_new.json

# build update-config
curl -X POST -F original=@$CONFIG_PATH/genesis.block.orig -F updated=@$CONFIG_PATH/genesis.block.new http://127.0.0.1:7059/configtxlator/compute/update-from-configs -F channel=testchainid > $CONFIG_PATH/config_update.block

# decode block back 
curl -X POST --data-binary @config_update.pb http://127.0.0.1:7059/protolator/decode/common.ConfigUpdate > $CONFIG_PATH/config_update.json
# wrap it into envelop
echo '{"payload":{"header":{"channel_header":{"channel_id":"testchainid", "type":2}},"data":{"config_update":'$(cat $CONFIG_PATH/config_update.json)'}}}' > $CONFIG_PATH/config_update_as_envelope.json
# encode as update TX
curl -X POST --data-binary @$CONFIG_PATH/config_update_as_envelope.json http://127.0.0.1:7059/protolator/encode/common.Envelope > $CONFIG_PATH/config_update.tx

cp $CONFIG_PATH/genesis.block.orig $CONFIG_PATH/genesis.block