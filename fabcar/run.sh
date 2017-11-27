#!/bin/bash

./startFabric.sh

if [ ! -d ./hfc-key-store ]; then
    echo "===> Enrolling Admin user."
    node enrollAdmin.js
    echo "===> Registering and enrolling User1 user"
    node registerUser.js
fi
echo "===> Making test query of the chaincode app."

SLEEP_TIME=5
echo "===> Waing ${SLEEP_TIME} seconds before proceeding."
sleep ${SLEEP_TIME}

node query.js
echo "===> Done."