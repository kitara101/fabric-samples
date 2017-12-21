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

shift 3
ORG=$1
ORG1=$ORG
ORG2=$2



echo "===> Deploying ${CHANNEL}."
. ./lib/create_channel.sh $CHANNEL $ORG
. ./lib/join_channel.sh $CHANNEL $ORG
#. ./lib/deploy_chaincode.sh $CHAINCODE $ORG 
# isntantiate to channel
#. ./lib/instantiate_chaincode.sh $CHAINCODE $CHANNEL $ORG "OR ('${ORG1}MSP.member')"
# populate with initial data
#. ./lib/init_chaincode.sh $CHAINCODE $CHANNEL $ORG 
while shift && [ "$1" != "" ];  do
    ORG=$1
    . ./lib/join_channel.sh $CHANNEL $ORG

    # deploy chaincode on peer
 #   . ./lib/deploy_chaincode.sh $CHAINCODE $ORG 
done

# deploy chaincode on peer
#. ./lib/deploy_chaincode.sh $CHAINCODE $ORG2  

#. ./lib/join_channel.sh $CHANNEL $ORG2 

# isntantiate to channel
#. ./lib/instantiate_chaincode.sh $CHAINCODE $CHANNEL $ORG2 "OR ('${ORG1}MSP.member','${ORG2}MSP.member')"
# populate with initial data
#. ./lib/init_chaincode.sh $CHAINCODE $CHANNEL $ORG2 




 echo "===> Channel ${CHANNEL} deployed."