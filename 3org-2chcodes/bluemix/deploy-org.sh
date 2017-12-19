#!/bin/sh -e

#kubectl create  -f ./org1/org1-volumes.yml

#kubectl create secret generic org1-peer-db --from-file=user=./org1/.db.username --from-file=password=./org1/.db.password

#kubectl create  -f ./org1/org1-services-couchdb.yml

kubectl create secret generic org1-ca  --from-file=ca-key=../crypto-config/peerOrganizations/org1.example.com/ca/9dfd37cc13ad2315800f4a3bf1f60fda81f005b3338f68a59585b29e98165a46_sk \
                                        --from-file=ca-cert=../crypto-config/peerOrganizations/org1.example.com/ca/ca.org1.example.com-cert.pem  \
 
kubectl create secret generic org1-msp  --from-file=admin-cert=../crypto-config/peerOrganizations/org1.example.com/msp/admincerts/Admin@org1.example.com-cert.pem \
                                        --from-file=ca-cert=../crypto-config/peerOrganizations/org1.example.com/msp/cacerts/ca.org1.example.com-cert.pem  

#kubectl create  -f ./org1/org1-services-peer.yml
