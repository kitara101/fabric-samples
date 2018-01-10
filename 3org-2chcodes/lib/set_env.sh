#!/bin/bash -e

if [ -f ./.env ]; then
  rm ./.env
fi
. ./.env_base

echo "${msg_sub}-----> Updating environment.${reset}"
CA_CRYPTO_DIR=./crypto-config/peerOrganizations/brand1.com/ca
CA_BRAND1_PRIVATE_KEY=$(ls -f1 ./crypto-config/peerOrganizations/brand1.com/ca | grep _sk)
CA_BRAND2_PRIVATE_KEY=$(ls -f1 ./crypto-config/peerOrganizations/brand2.com/ca | grep _sk)
CA_TRACELABEL_PRIVATE_KEY=$(ls -f1 ./crypto-config/ordererOrganizations/tracelabel.com/ca | grep _sk)
CA_DISTR_TRACELABEL_PRIVATE_KEY=$(ls -f1 ./crypto-config/peerOrganizations/distr.tracelabel.com/ca | grep _sk)
#CA_ORG5_PRIVATE_KEY=$(ls -f1 ./crypto-config/peerOrganizations/distributor2.com/ca | grep _sk)

# keep original env file
#if [ ! -e  ./.env_orig ]; then
 # cp .env .env_orig
#fi

cp ./.env_base ./.env
echo CA_BRAND1_PRIVATE_KEY=${CA_BRAND1_PRIVATE_KEY} >> ./.env
echo CA_BRAND2_PRIVATE_KEY=${CA_BRAND2_PRIVATE_KEY} >> ./.env
echo CA_TRACELABEL_PRIVATE_KEY=${CA_TRACELABEL_PRIVATE_KEY} >> ./.env
echo CA_DISTR_TRACELABEL_PRIVATE_KEY=${CA_DISTR_TRACELABEL_PRIVATE_KEY} >> ./.env
echo CA_ORG4_PRIVATE_KEY=${CA_ORG4_PRIVATE_KEY} >> ./.env
echo CA_ORG5_PRIVATE_KEY=${CA_ORG5_PRIVATE_KEY} >> ./.env

. ./.env
