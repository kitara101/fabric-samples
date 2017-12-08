## Howto

Fabric images: 1.1.0-preview

To test JS chaincode you need:
1) cd to ../basic-network
2) make sure that in 'docker-compose.yml'for peer0:
    - for 'peer0' service command is set to "peer node start --peer-chaincodedev=true"
    - for 'cli' service specified the folloing volume mount for js chaincode: '../chaincode/jscc:/opt/nodejs'
3) start network by running ./start.sh
4) cd to ../chaicode/jscc/
5) run 'npm install' to install modules
6) deploy chaincode with this command: 
    CORE_CHAINCODE_ID_NAME="jscc:v0" npm start -- --peer.address grpc://<peer0 ip>:7052
        or
    CORE_CHAINCODE_ID_NAME="jscc:v0" node jscc --peer.address grpc://<peer0 ip>:7052    
7) run cli: docker-compose run cli bash
8) in cli, install chaincode with the following command: peer chaincode install -l node -n jscc -v v0 -p /opt/nodejs/
9) in cli, instantiate chaincode with command: 
    peer chaincode instantiate -l node -n jscc -v v0 -C my-test-channel -c '{"args":["init","1","2"]}' -o orderer.example.com:7050
10) run query.js
