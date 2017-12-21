#!/bin/bash -e

./start.sh $1

if [ "$?" -ne 0 ]; then
    exit 1
fi

if [ !  -d ./node_modules ]; then
    npm install
fi


node enrollAdmin.js org1
node registerUser.js org1
node enrollAdmin.js org2
node registerUser.js org2
#node enrollAdmin.js org3
#node registerUser.js org3
#node enrollAdmin.js org4
#node registerUser.js org4
#node enrollAdmin.js org5
#node registerUser.js org5
node query.js channel-12 org1 org1
#node query.js channel-12 org2 org1
node query.js channel-12 org1 org2
#node query.js channel-23 org2 org3
echo "Quierying from partner's peer"
#node query.js channel-12 org4 org1
#node query.js channel-23 org5 org3
echo "Inserting transaction on own peer"

node invoke.js channel-12 org1 org1

echo "Inserting transaction on partners peer -- event hub should fail."
#node invoke.js channel-12 org1 org2
echo "The above operation should fail with event_hub subscription error. This is OK."