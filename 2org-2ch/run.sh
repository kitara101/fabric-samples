#!/bin/bash -e

./start.sh $1

if [ "$?" -ne 0 ]; then
    exit 1
fi

node enrollAdmin.js
node registerUser.js
node query.js
