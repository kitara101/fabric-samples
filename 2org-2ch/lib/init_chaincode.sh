########################################################
# Init chaincode with inital data
########################################################
# parameters:
# $1 - chaincode
# $2 - channel
# $3 - org on behalf of which the cannel will be created

CHAINCODE=$1
CHANNEL=$2
ORG=$3

echo "--> Invoking chaincode init fo '$CHAINCODE' in channel '$CHANNEL' of $ORG's peer0."
docker exec -e "CORE_PEER_ADDRESS=peer0.${ORG,}.example.com:7051" -e "CORE_PEER_LOCALMSPID=${ORG}MSP" -e "CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/${ORG,}.example.com/users/Admin@${ORG,}.example.com/msp" cli peer chaincode invoke -o orderer.example.com:7050 -C $CHANNEL -n $CHAINCODE -c '{"function":"initLedger","Args":[""]}'
