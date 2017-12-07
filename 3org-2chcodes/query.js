
'use strict';
/*
* Copyright IBM Corp All Rights Reserved
*
* SPDX-License-Identifier: Apache-2.0
*/
/*
 * Chaincode query
 */

var config = [
    {
        peer_port: 7051,
        msp:  'Org1MSP'
    },
    {
        peer_port: 7061,
        msp:  'Org2MSP'
    }    
];

let [,, org] = process.argv;
if (typeof (org) === "undefined" ) {
    console.log("Organization not specified, assuming 'org1'");
    org = "org1";
} else if (org !== "org1" && org !== "org2") {
    console.log(`Expecting 'org1' or 'org2', got ${org}. Assuming 'org1q`);
    org = "rg1";
} 

const Org = 'O' + org.substr(1);
const i = (org == "org1" ? 0 : 1);
const {peer_port: peerPort, msp: mspName} = config[i];

var Fabric_Client = require('fabric-client');
var path = require('path');
var util = require('util');
var os = require('os');

//
var fabric_client = new Fabric_Client();


// setup the fabric network
var channel_a = fabric_client.newChannel('channel-12');
	//channel_b = fabric_client.newChannel('channel-b');
let url = `grpc://localhost:${peerPort}`;
var peer = fabric_client.newPeer(url);
channel_a.addPeer(peer);
//channel_b.addPeer(peer);

//
var member_user = null;
var store_path = path.join(__dirname, 'hfc-key-store/' + org);
console.log('Store path:' + store_path);
console.log("Peer\'s url: " + url);
console.log('MSPName: ' + mspName);
var tx_id = null;

// create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
Fabric_Client.newDefaultKeyValueStore({ path: store_path
}).then((state_store) => {
	// assign the store to the fabric client
	fabric_client.setStateStore(state_store);
	var crypto_suite = Fabric_Client.newCryptoSuite();
	// use the same location for the state store (where the users' certificate are kept)
	// and the crypto store (where the users' keys are kept)
	var crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path});
	crypto_suite.setCryptoKeyStore(crypto_store);
	fabric_client.setCryptoSuite(crypto_suite);

	// get the enrolled user from persistence, this user will sign all requests
	return fabric_client.getUserContext('user1', true);
}).then((user_from_store) => {
	if (user_from_store && user_from_store.isEnrolled()) {
		console.log('--> Successfully loaded user1 from persistence');
		member_user = user_from_store;
	} else {
		throw new Error('--> !Failed to get user1.... run registerUser.js');
	}

	// queryCar chaincode function - requires 1 argument, ex: args: ['CAR4'],
	// queryAllCars chaincode function - requires no arguments , ex: args: [''],
	const request = {
		//targets : --- letting this default to the peers assigned to the channel
		chaincodeId: 'fabcar',
		fcn: 'queryAllCars',
		args: ['']
	};

	// send the query proposal to the peer
	return channel_a.queryByChaincode(request);
}).then((query_responses) => {
	console.log("--> Query to 'channel-a' has completed, checking results");
	// query_responses could have more than one  results if there multiple peers were used as targets
	if (query_responses && query_responses.length == 1) {
		if (query_responses[0] instanceof Error) {
			console.error("--> !error from query = ", query_responses[0]);
		} else {
			console.log("--> Response is ", query_responses[0].toString());
		}
	} else {
		console.log("--> No payloads were returned from query");
	}

	// queryCar chaincode function - requires 1 argument, ex: args: ['CAR4'],
	// queryAllCars chaincode function - requires no arguments , ex: args: [''],
	const request = {
		//targets : --- letting this default to the peers assigned to the channel
		chaincodeId: 'fabcar',
		fcn: 'queryAllCars',
		args: ['']
	};
	return channel_b.queryByChaincode(request);
}).then(query_responses => {
	console.log("--> Query to 'channel-b' has completed, checking results");
	// query_responses could have more than one  results if there multiple peers were used as targets
	if (query_responses && query_responses.length == 1) {
		if (query_responses[0] instanceof Error) {
			console.error("--> !error from query = ", query_responses[0]);
		} else {
			console.log("--> Response is ", query_responses[0].toString());
		}
	} else {
		console.log("--> No payloads were returned from query");
	}
}).catch((err) => {
	console.error('--> !Failed to query successfully :: ' + err);
});
