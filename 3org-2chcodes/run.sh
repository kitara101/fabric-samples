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
node query.js org1
#node enrollAdmin.js org2
#node registerUser.js org2
#node query.js org2
