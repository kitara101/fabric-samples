#!/bin/bash -e

echo "===> Generating crypto material"
# generate crypto material
if [ ! -f ./crypto-config/ordererOrganizations/tracelabel.com/ca/ca.tracelabel.com-cert.pem ]; then
  cryptogen generate --config=./crypto-config.yaml
fi
if [ "$?" -ne 0 ]; then
  echo "Failed to generate crypto material..."
  exit 1
fi

. ./lib/set_env.sh

# pepare cryptofiles for multi-ca server
cp ./crypto-config/ordererOrganizations/tracelabel.com/ca/*_sk ./crypto-config/ordererOrganizations/tracelabel.com/ca/ca-key.pem
cp ./crypto-config/peerOrganizations/distr.tracelabel.com/ca/*_sk ./crypto-config/peerOrganizations/distr.tracelabel.com/ca/ca-key.pem
rm -rf ./crypto-config/peerOrganizations/distributor1.com/msp
mkdir -p ./crypto-config/peerOrganizations/distributor1.com/msp

#FABRIC_START_TIMEOUT=0
echo "${msg}-----> Generating intermediate CA for distributors${reset}"
echo "-----> Adding intermediate CA's to 'TraceLabelMSP'"
docker-compose up -d ca.tracelabel.com
#docker-compose up -d --force-recreate --no-deps ca.cli
echo "--------> Waiting for 'ca.tracelabel.com' to start"
sleep $FABRIC_START_TIMEOUT
docker-compose stop ca.cli
docker-compose up -d ca.distr.tracelabel.com ca.cli
echo "--------> Waiting for 'ca.distr.tracelabel.com' to start"
sleep $FABRIC_START_TIMEOUT
#docker-compose exec ca.cli mkdir admin
echo "--------> Enrolling admin"
#docker-compose exec ca.cli export "FABRIC_CA_CLIENT_HOME=$PWD/admin"
docker-compose exec ca.cli fabric-ca-client enroll -u http://admin:adminpw@ca.distr.tracelabel.com:7054
echo "--------> Getting intermediate cert chain"
docker-compose exec ca.cli fabric-ca-client getcacert -u http://admin:adminpw@ca.distr.tracelabel.com:7054 --caname ca.admin.distr.tracelabel.com -M ./tracelabel
docker-compose exec ca.cli chmod -R a+rwx ./tracelabel
echo "-----> Done for 'TraceLabelMSP'"

echo "-----> Adding intermediate CA's to 'Distributor1MSP'"
echo "--------> Getting intermediate cert chain"
docker-compose exec ca.cli fabric-ca-client getcacert -u http://admin:adminpw@ca.distr.tracelabel.com:7054 --caname ca.distr1.distr.tracelabel.com -M ./distr1
echo "--------> Getting Admin certificate"
docker-compose exec ca.cli fabric-ca-client enroll -u http://admin:adminpw@ca.distr.tracelabel.com:7054 --caname ca.distr1.distr.tracelabel.com -M ./distr1/admin
docker-compose exec ca.cli chmod -R a+rwx ./distr1
docker-compose exec ca.cli mkdir ./distr1/admincerts
docker-compose exec ca.cli cp -r ./distr1/admin/signcerts/cert.pem ./distr1/admincerts/
echo "-----> Done for 'Distributor1MSP'"

echo "-----> Adding intermediate CA's to 'DistributorsMSP'"
echo "--------> Getting intermediate cert chain"
docker-compose exec ca.cli fabric-ca-client getcacert -u http://admin:adminpw@ca.distr.tracelabel.com:7054 --caname ca.admin.distr.tracelabel.com -M ./distributors
docker-compose exec ca.cli fabric-ca-client getcacert -u http://admin:adminpw@ca.distr.tracelabel.com:7054 --caname ca.distr1.distr.tracelabel.com -M ./distributors
echo "--------> Getting Admin certificate"
docker-compose exec ca.cli fabric-ca-client enroll -u http://admin:adminpw@ca.distr.tracelabel.com:7054 --caname ca.admin.distr.tracelabel.com -M ./distributors/admin
docker-compose exec ca.cli chmod -R a+rwx ./distributors
docker-compose exec ca.cli rm  ./distributors/admincerts/Admin@distr.tracelabel.com-cert.pem
docker-compose exec ca.cli cp -r ./distributors/admin/signcerts/cert.pem ./distributors/admincerts/
echo "-----> Done for 'DistributorsMSP'"


# copy TraceLabel to peers
cp -r ./crypto-config/ordererOrganizations/tracelabel.com ./crypto-config/peerOrganizations/
mkdir -p ./crypto-config/peerOrganizations/tracelabel.com/peers
cp -r ./crypto-config/peerOrganizations/tracelabel.com/orderers/* ./crypto-config/peerOrganizations/tracelabel.com/peers/


# exit
# #docker exec ca.cli chmod -R a+rw ./admin
# echo "--------> Registring peer0.tracelabel.com identity with Intermediate CA"
# OUT_TEXT=$(docker-compose exec ca.cli fabric-ca-client register -u http://${DISTR_CA} --id.name $PEER --id.type peer --id.affiliation distributors1)
# echo  "$OUT_TEXT"
#
# PASSWD=$(echo -e "$OUT_TEXT" | sed -ne 's/^.*Password: \(\w*\).*$/\1/p')
# echo "--------> Enrolling '$PEER' with password '$PASSWD'"
# docker-compose exec ca.cli fabric-ca-client enroll -u http://${PEER}:${PASSWD}@ca.distr.tracelabel.com:7054 -M ./$PEER
# # change mode to be able to copy on host
# docker-compose exec ca.cli chmod -R a+rwx ./
# # copy admin cert to new intermediate MSP
# mkdir -p $MSPDir/admincerts
# cp -r $CA_CLI_PATH/msp/signcerts/* $MSPDir/admincerts
# # copy peer's cryptodata
#
# cp -r $CA_CLI_PATH/$PEER/* $MSPDir
# # preapre additional admin's MSP for deployments
# ADMIN_MSP=./crypto-config/peerOrganizations/tracelabel.com/users/Admin@tracelabel.com
# mkdir -p $ADMIN_MSP
# cp -r $CA_CLI_PATH/msp $ADMIN_MSP
# mkdir $ADMIN_MSP/msp/admincerts
# cp -r $ADMIN_MSP/msp/signcerts/* $ADMIN_MSP/msp/admincerts/
#
# # prepare MSP for orderer.com
# ORDERER_MSP=./crypto-config/ordererOrganizations/tracelabel.com/orderers/orderer.tracelabel.com/msp
# cp -r $MSPDir/intermediatecerts $ORDERER_MSP

docker-compose stop ca.cli
