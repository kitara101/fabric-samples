###################################################
# Create the channels
###################################################
# parameters:
# $1 - name of the channel
# $2 - org on behalf of which the cannel will be created

CHANNEL=$1
ORG=$2

DOMAIN=$ORG
if [ "$DOMAIN" == "TraceLabel" ]; then
    DOMAIN=tracelabel
fi

echo "${msg_sub}-----> Creating channel '$CHANNEL'.${reset}"
docker exec -e "CORE_PEER_LOCALMSPID=${ORG}MSP" -e "CORE_PEER_MSPCONFIGPATH=/etc/hyperledger/msp/users/Admin@${DOMAIN,}.com/msp" peer0.${DOMAIN,}.com peer channel create -o $ORDERER -c $CHANNEL -f /etc/hyperledger/configtx/$CHANNEL.tx
