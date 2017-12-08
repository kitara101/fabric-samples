rm -fr ./hfc-key-store
cd ../basic-network
. ./.env
./stop.sh
./teardown.sh
./generate.sh
./start.sh


docker-compose -f ./docker-compose.yml up -d cli

CC_SRC_PATH=/opt/nodejs/

echo "===> Installing Node.js chaincode"
echo "--> installing"
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode install -n jscc -v v0 -p "$CC_SRC_PATH" -l node 
echo "--> instantiating chaincode"
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode instantiate -o orderer.example.com:7050 -C $CHANNEL -n jscc -l node -v v0 -c '{"Args":[""]}' -P "OR ('Org1MSP.member','Org2MSP.member')"
sleep 10
echo "--> callin init on chaincode"
docker exec -e "CORE_PEER_LOCALMSPID=Org1MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp" cli peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL -n jscc -c '{"function":"populate","Args":[""]}'
