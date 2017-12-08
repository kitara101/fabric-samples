'use strict';

var Fabric_Client = require('fabric-client');
var path = require('path');
var util = require('util');
var os = require('os');

//
var fabric_client = new Fabric_Client();
// setup the fabric network 
const 	channel_12 = fabric_client.newChannel('channel-12'),
		channel_23 = fabric_client.newChannel('channel-23');
let orgs = [
	{ 	org: "org1",
		url: "grpc://localhost:7051",
		msp: "Org1MSP"
	},
	{	org: "org2",
		url: "grpc://localhost:7061",
		msp: "Org1MSP"
	},
	{	org: "org3",
		url: "grpc://localhost:7071",
		msp: "Org1MSP"
	}
];

const request = {
	//targets : --- letting this default to the peers assigned to the channel
	chaincodeId: 'fabcar',
	fcn: 'queryAllCars',
	args: ['']
};

//
let org1_user = null, org2_user = null, org3_user = null;
var store_path_org1 = path.join(__dirname, 'hfc-key-store/' + orgs[0].org);
let store_path_org2 = path.join(__dirname, 'hfc-key-store/' + orgs[1].org);
let store_path_org3 = path.join(__dirname, 'hfc-key-store/' + orgs[2].org);
console.log('Store paths:\n' + store_path_org1 + '\n' + store_path_org2 + '\n' + store_path_org3);

var tx_id = null;


const org1Peer = fabric_client.newPeer(orgs[0].url);
const org2Peer = fabric_client.newPeer(orgs[1].url);
const org3Peer = fabric_client.newPeer(orgs[2].url);
channel_12.addPeer(org1Peer);
//channel_12.addPeer(org2Peer);
channel_23.addPeer(org2Peer);
channel_23.addPeer(org3Peer);

console.log('Querying channel-12 on org1 with org1\'s user');
// create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
Fabric_Client.newDefaultKeyValueStore({ path: store_path_org1
}).then((state_store) => {
	fabric_client.setStateStore(state_store);
	var crypto_suite = Fabric_Client.newCryptoSuite();
	var crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path_org1});
	crypto_suite.setCryptoKeyStore(crypto_store);
	fabric_client.setCryptoSuite(crypto_suite);
	return fabric_client.getUserContext('user1', true);
}).then((user_from_store) => {
	if (user_from_store && user_from_store.isEnrolled()) {
		console.log('--> Successfully loaded user1 for org1 from persistence');
		org1_user = user_from_store;
	} else {
		throw new Error('--> !Failed to get user1 for org1.... run registerUser.js');
	}

	return channel_12.queryByChaincode(request);
}).then((query_responses) => {
	console.log(`--> Query to channel-12 has completed, checking results`);
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
	
	// create user1 for org2
	return Fabric_Client.newDefaultKeyValueStore({ path: store_path_org2});
}).then(state_store => {	
	fabric_client.setStateStore(state_store);
	var crypto_suite = Fabric_Client.newCryptoSuite();
	var crypto_store = Fabric_Client.newCryptoKeyStore({path: store_path_org2});
	crypto_suite.setCryptoKeyStore(crypto_store);
	fabric_client.setCryptoSuite(crypto_suite);
	return fabric_client.getUserContext('user1', true);
}).then((user_from_store) => {
	if (user_from_store && user_from_store.isEnrolled()) {
		console.log('--> Successfully loaded user1 for org2 from persistence');
		org2_user = user_from_store;
	} else {
		throw new Error('--> !Failed to get user1 for org2.... run registerUser.js');
	}

	//return channel_12.queryByChaincode(request);
	console.log('Querying channel-12 on org2 with org2\'s user.');
	return channel_12.queryByChaincode(request);
}).then((query_responses) => {
	console.log(`--> Query to channel-12 has completed, checking results`);
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
	
	// create user1 for org2
	return Fabric_Client.newDefaultKeyValueStore({ path: store_path_org2});
}).catch((err) => {
	console.error('--> !Failed to query successfully :: ' + err);
});
