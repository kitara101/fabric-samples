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

echo "===> Deploying ${CONSORCIUM}."
. ./lib/create_channel.sh $CHANNEL $ORG1
. ./lib/join_channel.sh $CHANNEL $ORG1

# deploy chaincode on peer
. ./lib/deploy_chaincode.sh $CHAINCODE $ORG1  
# isntantiate to channel
. ./lib/instantiate_chaincode.sh $CHAINCODE $CHANNEL $ORG1 "OR ('${ORG1}MSP.member','${ORG2}MSP.member')"
# populate with initial data
. ./lib/init_chaincode.sh $CHAINCODE $CHANNEL $ORG1 

 . ./lib/join_channel.sh $CHANNEL $ORG2 
 echo "===> Consorcium ${CONSORCIUM} deployed."