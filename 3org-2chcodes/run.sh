#!/bin/bash -e

./start.sh $1

if [ "$?" -ne 0 ]; then
    exit 1
fi

if [ !  -d ./node_modules ]; then
    npm install
fi


node enrollAdmin.js brand1
node registerUser.js brand1
node enrollAdmin.js brand2
node registerUser.js brand2
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
echo "Quierying from partner's peer"
#node query.js channel-1 distributor1 brand1
#node query.js channel-2 distributor2 org3
echo "Inserting transaction on own peer"

node invoke.js channel-1 brand1 brand1
node invoke.js channel-2 brand2 brand2
echo "Inserting transaction on partners peer -- event hub should fail."
#node invoke.js channel-1 brand1 brand2
echo "The above operation should fail with event_hub subscription error. This is OK."