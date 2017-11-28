#!/bin/bash

./start.sh $1

node enrollAdmin.js
node registerUser.js
node query.js
