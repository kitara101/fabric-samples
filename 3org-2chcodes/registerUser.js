'use strict';
/*
* Copyright IBM Corp All Rights Reserved
*
* SPDX-License-Identifier: Apache-2.0
*/
/*
 * Register and Enroll a user
 */

var config = {
    brand1: {
        ca_port: 7054,
        ca_name: 'ca.brand1.com',
        msp:  'Brand1MSP',
        affiliation_root: 'brand1',
        affiliation: 'department1'
    },
    brand2: {
        ca_port: 7055,
        ca_name: 'ca.brand2.com',
        msp:  'Brand2MSP',
        affiliation_root: 'brand2',
        affiliation: 'department1'
    },
    org3: {
        ca_port: 7056,
        ca_name: 'ca.org3.example.com',
        msp:  'Org3MSP'
    },
    distributor1: {
      ca_port: 7058,
      ca_name: 'ca.distr.tracelabel.com',
      msp:  'TraceLabelMSP'
    },
    distributor2: {
      ca_port: 7058,
      ca_name: 'ca.distr.tracelabel.com',
      msp:  'TraceLabelMSP',
      affiliation_root: 'admin',
      affiliation: 'default'
    },
    tracelabel: {
      ca_port: 7057,
      ca_name: 'ca.tracelabel.com',
      msp:  'TraceLabelMSP'
    },
    admin_distributors: {
      ca_port: 7058,
      ca_name: 'ca.admin.distr.tracelabel.com',
      msp:  'TraceLabelMSP',
      affiliation_root: 'administration',
      affiliation: 'default'
    }
};

let [,, org] = process.argv;
if (typeof (org) === "undefined" ) {
    console.log("Organization not specified, assuming 'brand1'");
    org = "brand1";
}

const Org = 'O' + org.substr(1);
const {ca_port: caPort, ca_name: caName, msp: mspName, affiliation_root: aff_root, affiliation: aff_unit} = config[org];

var Fabric_Client = require('fabric-client');
var Fabric_CA_Client = require('fabric-ca-client');

var path = require('path');
var util = require('util');
var os = require('os');

//
var fabric_client = new Fabric_Client();
var fabric_ca_client = null;
var admin_user = null;
var member_user = null;
var store_path = path.join(__dirname, 'hfc-key-store/' + org);

console.log(`\n[ Registering 'user1' user for ${org} ]\n`);
console.log(' Store path:'+store_path);

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
    var	tlsOptions = {
    	trustedRoots: [],
    	verify: false
    };
    // be sure to change the http to https when the CA is running TLS enabled
    fabric_ca_client = new Fabric_CA_Client(`http://localhost:${caPort}`, null , caName, crypto_suite);

    // first check to see if the admin is already enrolled
    return fabric_client.getUserContext('admin', true);
}).then((user_from_store) => {
    if (user_from_store && user_from_store.isEnrolled()) {
        console.log('Successfully loaded admin from persistence');
        admin_user = user_from_store;
    } else {
        throw new Error('Failed to get admin.... run enrollAdmin.js');
    }

    // at this point we should have the admin user
    // first need to register the user with the CA server
    // const aff_root = ( org === "distributor1" ? "distributors1" : org)
    // const aff_unit = ( org === "distributor1" ? "distributor1" : "department1")
    return fabric_ca_client.register({enrollmentID: 'user1', affiliation: `${aff_root}.${aff_unit}`}, admin_user);
}).then((secret) => {
    // next we need to enroll the user with CA server
    console.log('Successfully registered user1 - secret:'+ secret);

    return fabric_ca_client.enroll({enrollmentID: 'user1', enrollmentSecret: secret});
}).then((enrollment) => {
  console.log('Successfully enrolled member user "user1" ');
  return fabric_client.createUser(
     {username: 'user1',
     mspid: mspName,
     cryptoContent: { privateKeyPEM: enrollment.key.toBytes(), signedCertPEM: enrollment.certificate }
     });
}).then((user) => {
     member_user = user;

     return fabric_client.setUserContext(member_user);
}).then(()=>{
     console.log('User1 was successfully registered and enrolled and is ready to intreact with the fabric network');

}).catch((err) => {
    console.error('Failed to register: ' + err);
	if(err.toString().indexOf('Authorization') > -1) {
		console.error('Authorization failures may be caused by having admin credentials from a previous CA instance.\n' +
		'Try again after deleting the contents of the store directory '+store_path);
	}
});
