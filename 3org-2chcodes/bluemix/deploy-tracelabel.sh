#!/bin/sh -e

cd tracelabel

#kubectl apply  -f ./volumes.yml




CA_TRACELABEL_PRIVATE_KEY=$(ls -f1 ../../crypto-config/ordererOrganizations/tracelabel.com/ca | grep _sk)
#kubectl create secret generic tracelabel-ca  --from-file=../../crypto-config/peerOrganizations/tracelabel.com/ca/$CA_TRACELABEL_PRIVATE_KEY \
#                                       --from-file=../../crypto-config/peerOrganizations/tracelabel.com/ca/ca.tracelabel.com-cert.pem  
 
#kubectl create secret generic tracelabel-msp  --from-file=admin-cert=../../crypto-config/peerOrganizations/tracelabel.com/msp/admincerts/Admin@tracelabel.com-cert.pem \
#                                        --from-file=ca-cert=../../crypto-config/peerOrganizations/tracelabel.com/msp/cacerts/ca.tracelabel.com-cert.pem  

#kubectl apply  -f ./service-ca.yml


#kubectl create secret generic orderer-block  --from-file=../../config/genesis.block
#kubectl create secret generic orderer-msp   --from-file=admin_cert=../../crypto-config/ordererOrganizations/tracelabel.com/orderers/orderer.tracelabel.com/msp/admincerts/Admin@tracelabel.com-cert.pem \
#                                            --from-file=../../crypto-config/ordererOrganizations/tracelabel.com/orderers/orderer.tracelabel.com/msp/cacerts \
#                                            --from-file=../../crypto-config/ordererOrganizations/tracelabel.com/orderers/orderer.tracelabel.com/msp/keystore \
#                                            --from-file=../../crypto-config/ordererOrganizations/tracelabel.com/orderers/orderer.tracelabel.com/msp/signcerts \
#                                            --from-file=../../crypto-config/ordererOrganizations/tracelabel.com/orderers/orderer.tracelabel.com/msp/tlscacerts

#kubectl apply -f tracelabel/service-orderer.yml


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
