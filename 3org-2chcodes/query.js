'use strict';

var Fabric_Client = require('fabric-client');
var path = require('path');
var util = require('util');
var os = require('os');

//
var fabric_client = new Fabric_Client();
// setup the fabric network
const 	channel_12 = fabric_client.newChannel('channel-1'),
		channel_23 = fabric_client.newChannel('channel-2');
let config = {
	brand1: {
		userOrg: "brand1",
		url: "grpc://localhost:7051",
		storePath: path.join(__dirname, 'hfc-key-store/brand1')
	},
	brand2: {
		userOrg: "brand2",
		url: "grpc://localhost:7061",
		storePath: path.join(__dirname, 'hfc-key-store/brand2')
	},
	distributor1: {
		ca_port: 7058,
		url: 'grpc://localhost:7071',
		storePath: path.join(__dirname, 'hfc-key-store/distributor1')
	},
	distributor2: {
		ca_port: 7058,
		url: 'grpc://localhost:7071',
		storePath: path.join(__dirname, 'hfc-key-store/distributor2')
	},
	tracelabel: {
		ca_port: 7058,
		url: 'grpc://localhost:7071',
		storePath: path.join(__dirname, 'hfc-key-store/tracelabel')
	},
	admin_distributors: {
		url: 'grpc://localhost:7071',
		storePath: path.join(__dirname, 'hfc-key-store/admin_distributors')
	}
};

let [,, channelName, userOrg, peerOrg] = process.argv;
//const userOrg = "org3";
//const peerOrg = "brand1";
const storePath = config[userOrg].storePath;
const peer = fabric_client.newPeer(config[peerOrg].url);
const channel = (channelName === "channel-1" ? channel_12 : channel_23);
channel.addPeer(peer);


const request = {
	//targets : --- letting this default to the peers assigned to the channel
	chaincodeId: 'fabcar',
	fcn: 'queryAllCars',
	args: ['']
};


let user = null;
console.log(`\n[ Querying \"${channel.getName()}\", user -> ${userOrg}, peer -> ${peerOrg} ]\n`);
// create the key value store as defined in the fabric-client/config/default.json 'key-value-store' setting
Fabric_Client.newDefaultKeyValueStore({ path: storePath
}).then((state_store) => {
	fabric_client.setStateStore(state_store);
	var crypto_suite = Fabric_Client.newCryptoSuite();
	var crypto_store = Fabric_Client.newCryptoKeyStore({path: storePath});
	crypto_suite.setCryptoKeyStore(crypto_store);
	fabric_client.setCryptoSuite(crypto_suite);
	return fabric_client.getUserContext('user1', true);
}).then((user_from_store) => {
	if (user_from_store && user_from_store.isEnrolled()) {
		console.log('--> Successfully loaded user1 from persistence');
		user = user_from_store;
	} else {
		throw new Error('--> !Failed to get user1.... run registerUser.js');
	}

	return channel.queryByChaincode(request);
}).then((query_responses) => {
	console.log(`--> Query to ${channel.getName()} has completed, checking results`);
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

	// create user1 for brand2
	return;
}).catch((err) => {
	console.error('--> !Failed to query successfully :: ' + err);
});
