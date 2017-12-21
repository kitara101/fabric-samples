#!/bin/sh -e

#kubectl create  -f ./brand1/brand1-volumes.yml

#kubectl create secret generic brand1-peer-db --from-file=user=./brand1/.db.username --from-file=password=./brand1/.db.password

#kubectl create  -f ./brand1/brand1-services-couchdb.yml

kubectl create secret generic brand1-ca  --from-file=ca-key=../crypto-config/peerOrganizations/brand1.com/ca/9dfd37cc13ad2315800f4a3bf1f60fda81f005b3338f68a59585b29e98165a46_sk \
                                        --from-file=ca-cert=../crypto-config/peerOrganizations/brand1.com/ca/ca.brand1.com-cert.pem  \
 
kubectl create secret generic brand1-msp  --from-file=admin-cert=../crypto-config/peerOrganizations/brand1.com/msp/admincerts/Admin@brand1.com-cert.pem \
                                        --from-file=ca-cert=../crypto-config/peerOrganizations/brand1.com/msp/cacerts/ca.brand1.com-cert.pem  

#kubectl create  -f ./brand1/brand1-services-peer.yml
