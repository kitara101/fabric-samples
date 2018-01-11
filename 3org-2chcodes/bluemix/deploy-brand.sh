#!/bin/bash

if [ $# -lt 1 ]; then
   echo -e "brand argument is not specified.\nexiting.\n"
   exit
elif [ "$1" != "brand-1" ] && [ "$1" != "brand-2" ]; then
   echo -e "argument must be \"brand-(1,2)\".\nexiting.\n"
   exit
fi

# load env
if [ -f ../.env ]; then
  . ../.env
else
  . ../.env_base
fi



BRAND=$1
CONFIG=$BRAND
BRAND_SHORT=$(echo $BRAND | tr -d "-")

echo "${msg}===> Deploying ${BRAND} to Bluemix.${reset}"

CA_PRIVATE_KEY=$(ls -f1 ../crypto-config/peerOrganizations/${BRAND_SHORT}.com/ca | grep _sk)
PEER_PRIVATE_KEY=$(ls -f1 ../crypto-config/peerOrganizations/${BRAND_SHORT}.com/peers/peer0.${BRAND_SHORT}.com/msp/keystore | grep _sk)
PEER_SIGN_CERT=$(ls -f1 ../crypto-config/peerOrganizations/${BRAND_SHORT}.com/peers/peer0.${BRAND_SHORT}.com/msp/signcerts | grep pem)


#### Deploying CA
echo "${msg_sub}-----> deploying CA${reset}"
RES_NAME=${BRAND}-ca
echo "--------> checking secret '${RES_NAME}'${reset}"
output=$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME}  --from-file=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/ca/$CA_PRIVATE_KEY \
                                              --from-file=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/ca/ca.${BRAND_SHORT}.com-cert.pem
else
   echo "--------> exists${reset}"
fi

#### creating secret for CA's MSP
RES_NAME=${BRAND}-msp
echo "--------> checking secret '${RES_NAME}'${reset}"
$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
  echo "--------> creating secret '${RES_NAME}'${reset}"
  kubectl create secret generic ${RES_NAME}  --from-file=admin-cert=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/msp/admincerts/Admin@${BRAND_SHORT}.com-cert.pem \
                                             --from-file=ca-cert=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/msp/cacerts/ca.${BRAND_SHORT}.com-cert.pem
else
   echo "--------> exists${reset}"
fi

echo "--------> creating service for CA ${reset}"
kubectl apply  -f ${CONFIG}/service-ca.yml

echo "${msg_sub}-----> CA service done${reset}"


#### Deploying peer
echo "${msg_sub}-----> deploying Peer0${reset}"
RES_NAME=${BRAND}-peer-db
echo "--------> checking secret '${RES_NAME}'${reset}"
$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME} --from-file=user=${CONFIG}/.db.username --from-file=password=${CONFIG}/.db.password
else
   echo "--------> exists${reset}"
fi


RES_NAME=${BRAND}-peer-msp
echo "--------> checking secret '${RES_NAME}'${reset}"
$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME}   \
                                            --from-file=admin_cert=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/peers/peer0.${BRAND_SHORT}.com/msp/admincerts/Admin@${BRAND_SHORT}.com-cert.pem \
                                            --from-file=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/peers/peer0.${BRAND_SHORT}.com/msp/cacerts \
                                            --from-file=private_key=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/peers/peer0.${BRAND_SHORT}.com/msp/keystore/$PEER_PRIVATE_KEY \
                                            --from-file=sign_cert=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/peers/peer0.${BRAND_SHORT}.com/msp/signcerts/$PEER_SIGN_CERT \
                                            --from-file=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/peers/peer0.${BRAND_SHORT}.com/msp/tlscacerts
else
   echo "--------> exists${reset}"
fi

RES_NAME=${BRAND}-peer-users
echo "--------> checking secret '${RES_NAME}'${reset}"
$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME}   \
                                            --from-file=admin_cert=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/users/Admin@${BRAND_SHORT}.com/msp/admincerts/Admin@${BRAND_SHORT}.com-cert.pem \
                                            --from-file=ca_cert=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/users/Admin@${BRAND_SHORT}.com/msp/cacerts/ca.${BRAND_SHORT}.com-cert.pem
else
   echo "--------> exists${reset}"
fi

echo "--------> creating persistent volume for couchdb ${reset}"
kubectl apply -f ${CONFIG}/volumes.yml
echo "--------> creating couchdb service${reset}"
kubectl apply -f ${CONFIG}/service-couchdb.yml
#kubectl apply -f ${CONFIG}/service-peer.yml

echo "${msg}===> ${BRAND} deployed to Bluemix.${reset}"