###################################################
# Joins the channels
###################################################
# parameters:
# $1 - name of the channel
# $2 - org on behalf of which the cannel will be created

CHANNEL=$1
ORG=$2


echo "------> Joining channel '$CHANNEL' by '$ORG's peer0."
docker exec -e "CORE_PEER_LOCALMSPID=${ORG}MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@${ORG,}.example.com/msp" peer0.${ORG,}.example.com peer channel fetch config $CHANNEL.block -o orderer.example.com:7050 -c $CHANNEL
docker exec -e "CORE_PEER_LOCALMSPID=${ORG}MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@${ORG,}.example.com/msp" peer0.${ORG,}.example.com peer channel join -b $CHANNEL.block




