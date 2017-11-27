#!/bin/bash
./stop.sh

echo "===> Removing enrollment data."
rm -fr ./hfc-key-store

cd ../basic-network
./teardown.sh


