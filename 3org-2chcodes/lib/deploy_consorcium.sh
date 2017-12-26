#####################################################
# Deploy chaincode to the specified peer and channel
#####################################################
# parameters:
# $1 - consorcium
# $2 - chaincode
# $3 - channel
# $4 - 1st company
# $5 - 2nd company

CONSORCIUM=$1
CHAINCODE=$2
CHANNEL=$3
ORG1=$4
ORG2=$5

echo "${msg}===> Deploying ${CONSORCIUM}.${reset}"
. ./lib/create_channel.sh $CHANNEL $ORG1
. ./lib/join_channel.sh $CHANNEL $ORG1
# deploy chaincode on peer
. ./lib/deploy_chaincode.sh $CHAINCODE $ORG1
# deploy chaincode on peer
#if [ "$ORG2" == "Org3" ]; then
    . ./lib/deploy_chaincode.sh $CHAINCODE $ORG2
#fi
. ./lib/join_channel.sh $CHANNEL $ORG2

# isntantiate to channel
. ./lib/instantiate_chaincode.sh $CHAINCODE $CHANNEL $ORG1 "OR ('${ORG1}MSP.member','${ORG2}MSP.member')"
# populate with initial data
. ./lib/init_chaincode.sh $CHAINCODE $CHANNEL $ORG1




 echo "${msg}===> Consorcium ${CONSORCIUM} deployed.${reset}"
