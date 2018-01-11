#!/bin/bash


# load env
if [ -f ../.env ]; then
  . ../.env
else
  . ../.env_base
fi



BRAND=tracelabel
CONFIG=$BRAND
BRAND_SHORT=$BRAND

echo "${msg}===> Deploying ${BRAND} to Bluemix.${reset}"


CA_PRIVATE_KEY=$(ls -f1 ../crypto-config/ordererOrganizations/${BRAND_SHORT}.com/ca | grep _sk)
PEER_PRIVATE_KEY=$(ls -f1 ../crypto-config/peerOrganizations/${BRAND_SHORT}.com/peers/peer0.${BRAND_SHORT}.com/msp/keystore | grep _sk)
PEER_SIGN_CERT=$(ls -f1 ../crypto-config/peerOrganizations/${BRAND_SHORT}.com/peers/peer0.${BRAND_SHORT}.com/msp/signcerts | grep pem)

#### Deploying CA
echo "${msg_sub}-----> deploying CA${reset}"

# default-ca secret
RES_NAME=${BRAND}-default-ca
echo "--------> checking secret '${RES_NAME}'${reset}"
output=$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME} \
                                              --from-file=fabric-ca-server-config.yaml=../resource/bluemix-${BRAND_SHORT}-default-fabric-ca-server-config.yaml
else
   echo "--------> exists${reset}"
fi

## secret for ca1
RES_NAME=${BRAND}-ca1
echo "--------> checking secret '${RES_NAME}'${reset}"
output=$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME}  --from-file=ca-key.pem=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/ca/$CA_PRIVATE_KEY \
                                              --from-file=ca-cert.pem=../crypto-config/peerOrganizations/${BRAND_SHORT}.com/ca/ca.${BRAND_SHORT}.com-cert.pem \
                                              --from-file=fabric-ca-config.yaml=../resource/bluemix-${BRAND_SHORT}-fabric-ca-server-config.yaml
else
   echo "--------> exists${reset}"
fi

## secret for ca2
RES_NAME=${BRAND}-ca2
echo "--------> checking secret '${RES_NAME}'${reset}"
output=$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME}  --from-file=ca-key.pem=../crypto-config/peerOrganizations/distr.tracelabel.com/ca/ca-key.pem \
                                              --from-file=ca-cert.pem=../crypto-config/peerOrganizations/distr.${BRAND_SHORT}.com/ca/ca.distr.${BRAND_SHORT}.com-cert.pem \
                                              --from-file=fabric-ca-config.yaml=../resource/bluemix-distr-fabric-ca-server-config.yaml
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


#kubectl apply -f ${CONFIG}/volumes.yml

echo "--------> creating service for CA ${reset}"
kubectl apply  -f ${CONFIG}/service-ca.yml

echo "${msg_sub}-----> CA service done${reset}"



#### Deploying orderer
echo "${msg_sub}-----> deploying CA${reset}"
RES_NAME=${BRAND}-orderer-block
echo "--------> generating secret '${RES_NAME}'${reset}"
$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME}  --from-file=../config/genesis.block
else
   echo "--------> exists${reset}"
fi

####
RES_NAME=${BRAND}-orderer-msp
echo "--------> checking secret '${RES_NAME}'${reset}"
$(kubectl get secret ${RES_NAME} > /dev/null 2>&1 )
if [ $? -eq 1 ]; then
   echo "--------> creating secret '${RES_NAME}'${reset}"
   kubectl create secret generic ${RES_NAME}    \
                                            --from-file=admin_cert=../crypto-config/ordererOrganizations/${BRAND_SHORT}.com/orderers/orderer.${BRAND_SHORT}.com/msp/admincerts/Admin@${BRAND_SHORT}.com-cert.pem \
                                            --from-file=../crypto-config/ordererOrganizations/${BRAND_SHORT}.com/orderers/orderer.${BRAND_SHORT}.com/msp/cacerts \
                                            --from-file=../crypto-config/ordererOrganizations/${BRAND_SHORT}.com/orderers/orderer.${BRAND_SHORT}.com/msp/keystore \
                                            --from-file=../crypto-config/ordererOrganizations/${BRAND_SHORT}.com/orderers/orderer.${BRAND_SHORT}.com/msp/signcerts \
                                            --from-file=../crypto-config/ordererOrganizations/${BRAND_SHORT}.com/orderers/orderer.${BRAND_SHORT}.com/msp/tlscacerts
else
   echo "--------> exists${reset}"
fi

kubectl apply -f tracelabel/service-orderer.yml
exit

# run peer
#kubectl create secret generic tracelabel-peer-db --from-file=user=.db.username --from-file=password=.db.password
#kubectl create secret generic tracelabel-peer-msp   \
#                                            --from-file=admin_cert=../../crypto-config/peerOrganizations/tracelabel.com/peers/peer0.tracelabel.com/msp/admincerts/Admin@tracelabel.com-cert.pem \
#                                            --from-file=../../crypto-config/peerOrganizations/tracelabel.com/peers/peer0.tracelabel.com/msp/cacerts \
#                                            --from-file=../../crypto-config/peerOrganizations/tracelabel.com/peers/peer0.tracelabel.com/msp/keystore \
#                                            --from-file=../../crypto-config/peerOrganizations/tracelabel.com/peers/peer0.tracelabel.com/msp/signcerts \
#                                            --from-file=../../crypto-config/peerOrganizations/tracelabel.com/peers/peer0.tracelabel.com/msp/tlscacerts

#kubectl create secret generic tracelabel-peer-users   \
#                                            --from-file=admin_cert=../../crypto-config/peerOrganizations/tracelabel.com/users/Admin@tracelabel.com/msp/admincerts/Admin@tracelabel.com-cert.pem \
#                                            --from-file=ca_cert=../../crypto-config/peerOrganizations/tracelabel.com/users/Admin@tracelabel.com/msp/cacerts/ca.tracelabel.com-cert.pem \




#kubectl apply  -f ./service-couchdb.yml
#kubectl apply  -f ./service-peer.yml
#kubectl apply -f ./service-peer.yml
