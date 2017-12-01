###################################################
# Create the channels
###################################################
# parameters:
# $1 - name of the channel
# $2 - org on behalf of which the cannel will be created

CHANNEL=$1
ORG=$2

echo "===> Creating channel '$CHANNEL'."
docker exec -e "CORE_PEER_LOCALMSPID=${ORG}MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@${ORG,}.example.com/msp" peer0.${ORG,}.example.com peer channel create -o orderer.example.com:7050 -c $CHANNEL -f /etc/hyperledger/configtx/$CHANNEL.tx