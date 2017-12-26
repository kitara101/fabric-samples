#!/bin/bash

node enrollAdmin.js brand1
node registerUser.js brand1
node enrollAdmin.js brand2
node registerUser.js brand2
node enrollAdmin.js tracelabel
node registerUser.js tracelabel
node enrollAdmin.js admin_distributors
node registerUser.js admin_distributors
#node enrollAdmin.js org3
#node registerUser.js org3
#node enrollAdmin.js distributor1
#node registerUser.js distributor1
#node enrollAdmin.js distributor2
#node registerUser.js distributor2
node query.js channel-1 brand1 brand1
#node query.js channel-1 brand2 brand1
#node query.js channel-1 brand1 brand2
node query.js channel-2 brand2 brand2
node query.js channel-1 admin_distributors tracelabel
echo "Quierying from partner's peer"
#node query.js channel-1 distributor1 brand1
#node query.js channel-2 distributor2 org3
echo "Testing inserting transactions"

node invoke.js channel-1 brand1 brand1
node invoke.js channel-2 brand2 brand2
node invoke.js channel-2 admin_distributors tracelabel
