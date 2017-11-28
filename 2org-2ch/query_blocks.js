'use strict'

var Fabric_Client = require('fabric-client');
var path = require('path');
var util = require('util');
var os = require('os');
var user = 'admin';

var fabric_client = new Fabric_Client();
var channel_a = fabric_client.newChannel('channel-a');
var peer = fabric_client.newPeer('grpc://localhost:7051');
channel_a.addPeer(peer);

var member_user = null;
var store_path = path.join(__dirname, 'hfc-key-store');
console.log('Store path:'+store_path);
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
	return fabric_client.getUserContext(user, true);
}).then((user_from_store) => {
	if (user_from_store && user_from_store.isEnrolled()) {
		console.log(`--> Successfully loaded ${user} from persistence`);
		member_user = user_from_store;
	} else {
		throw new Error(`--> !Failed to get ${user}`);
	}
	
	// queryCar chaincode function - requires 1 argument, ex: args: ['CAR4'],
	// queryAllCars chaincode function - requires no arguments , ex: args: [''],
	const request = {
		//targets : --- letting this default to the peers assigned to the channel
		chaincodeId: 'fabcar',
		fcn: 'queryAllCars',
		args: ['']
	};
	console.log("*************\nMaking 'queryInfo' call for channel-a...");
	return channel_a.queryInfo(peer,true);
}).then(resp => {
	console.log('Results: ')
	console.log(`Block height:      ${resp.height}`);
	console.log(`Block hash:        ${resp.currentBlockHash.toBuffer().toString('hex')}`);
	console.log(`Prev block hash:   ${resp.currentBlockHash.toBuffer().toString('hex')}`);

	console.log("*************\nMaking 'getOrganizations' call for channel-a...");
	return channel_a.getOrganizations();
}).then(resp => {
	console.log('Results: ')
	console.log(`Count of organizations is ${resp.length}`);

	console.log("*************\nMaking 'getPeers' call for channel-a...");
	return channel_a.getPeers();
}).then(resp => {
	console.log('Results: ')
	console.log(`Number:  ${resp.length}`);
	console.log('Url: ' + resp[0].toString());

	console.log("*************\nMaking 'queryBlock' call for channel-a...");
	return channel_a.queryBlock(1);
}).then(resp => {
	
	console.log('Results: ');
/*	var {header: header_} = resp;
	console.log(resp);
	var {number: block_num, previous_hash: prev_hash, data_hash: data_hash} = header_;
	console.log("Header: ");
	console.log(`\tblock_num: ${resp.header.number}\n\tprev_hash: ${resp.header.previous_hash}\n\tdata_hash: ${resp.header.data_hash}`);
	var {data:{data: [{signature: sign, payload: payload},  ]}} = resp;
*/	var blockText = 

`
Header:
	block_num: ${resp.header.number}
	prev_hash: ${resp.header.previous_hash}
	data_hash: ${resp.header.data_hash}	
Data:
	signature ${resp.data.data[0].signature.toString('hex').substr(0, 64)}
	payload:
		header: 
			channel_header:
				type:      ${resp.data.data[0].payload.header.channel_header.type}
				version:   ${resp.data.data[0].payload.header.channel_header.version}
				timestamp: ${resp.data.data[0].payload.header.channel_header.timestamp}
				channel:   ${resp.data.data[0].payload.header.channel_header.channel}
				tx_id:     ${resp.data.data[0].payload.header.channel_header.tx_id}
				epoch:     ${resp.data.data[0].payload.header.channel_header.epoch}
			singature_header:
				creator:
					Mspid:  ${resp.data.data[0].payload.header.signature_header.creator.Mspid}
					IdBytes:${resp.data.data[0].payload.header.signature_header.creator.IdBytes}
					nonce:  ${resp.data.data[0].payload.header.signature_header.creator.nonce}
		data:
			actions: ${resp.data.data[0].payload.data.actions.length}
				[0]: ${resp.data.data[0].payload.data.actions[0]}`; 
	console.log(blockText);
	//for (var p in payload) { console.log(p);}
}).catch((err) => {
	console.error('--> !Failed to query successfully :: ' + err);
});
