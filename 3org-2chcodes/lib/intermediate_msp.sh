#!/bin/bash -e
#
# $1 - MSP path
# $2 - node identity

MSPDir=$1
PEER=$2
#$(date +%s)

echo "-----> Generating intermediate CA's MSP for peer '$PEER'"

docker-compose up -d ca.tracelabel.com ca.distr.tracelabel.com ca.cli
#docker-compose up -d --force-recreate --no-deps ca.cli
echo "--------> Waiting for CA to start"
sleep $FABRIC_START_TIMEOUT
#docker-compose exec ca.cli mkdir admin
echo "--------> Enrolling admin"
#docker-compose exec ca.cli export "FABRIC_CA_CLIENT_HOME=$PWD/admin"
docker-compose exec ca.cli fabric-ca-client enroll -u http://admin:adminpw@${DISTR_CA}



#docker exec ca.cli chmod -R a+rw ./admin
echo "--------> Registring peer0.tracelabel.com identity with Intermediate CA"
OUT_TEXT=$(docker-compose exec ca.cli fabric-ca-client register -u http://${DISTR_CA} --id.name $PEER --id.type peer --id.affiliation distributors1)
echo  "$OUT_TEXT"

PASSWD=$(echo -e "$OUT_TEXT" | sed -ne 's/^.*Password: \(\w*\).*$/\1/p')
echo "--------> Enrolling '$PEER' with password '$PASSWD'"
docker-compose exec ca.cli fabric-ca-client enroll -u http://${PEER}:${PASSWD}@ca.distr.tracelabel.com:7054 -M ./$PEER
# change mode to be able to copy on host
docker-compose exec ca.cli chmod -R a+rwx ./
# copy admin cert to new intermediate MSP
mkdir -p $MSPDir/admincerts
cp -r $CA_CLI_PATH/msp/signcerts/* $MSPDir/admincerts
# copy peer's cryptodata

cp -r $CA_CLI_PATH/$PEER/* $MSPDir
# preapre additional admin's MSP for deployments
ADMIN_MSP=./crypto-config/peerOrganizations/tracelabel.com/users/Admin@tracelabel.com
mkdir -p $ADMIN_MSP
cp -r $CA_CLI_PATH/msp $ADMIN_MSP
mkdir $ADMIN_MSP/msp/admincerts
cp -r $ADMIN_MSP/msp/signcerts/* $ADMIN_MSP/msp/admincerts/

# prepare MSP for orderer.com
ORDERER_MSP=./crypto-config/ordererOrganizations/tracelabel.com/orderers/orderer.tracelabel.com/msp
cp -r $MSPDir/intermediatecerts $ORDERER_MSP

docker-compose stop ca.cli


#mkdir ./crypto-config/peerOrganizations/tracelabel.com/peers/peer0.tracelabel.com/msp/admincerts
#cp ./crypto-config/ca.cli/msp/signcert/* ./crypto-config/peerOrganizations/tracelabel.com/peers/peer0.tracelabel.com/msp/admincerts
