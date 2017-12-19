'use strict';
/*
* Copyright IBM Corp All Rights Reserved
*
* SPDX-License-Identifier: Apache-2.0
*/
/*
 * Enroll the admin user
 */

var path = require('path');
var util = require('util');
var os = require('os');

var config = [
    {
        ca_port: 7054,
        ca_name: 'ca.org1.example.com',
        msp:  'Org1MSP'
    },
    {
        ca_port: 7055,
        ca_name: 'ca.org2.example.com',
        msp:  'Org2MSP'
    },   
    {
        ca_port: 7056,
        ca_name: 'ca.org3.example.com',
        msp:  'Org3MSP'
    } 
];

let [,, org] = process.argv;
if (typeof (org) === "undefined" ) {
    console.log("Organization not specified, assuming 'org1'");
    org = "org1";
} else if (org !== "org1" && org !== "org2" && org !== "org3") {
    console.log(`Expecting 'org1', 'org2' or 'org3', got ${org}. Assuming 'org1`);
    org = "rg1";
} 

const Org = 'O' + org.substr(1);
const i = (org == "org1" ? 0 : (org == "org2" ? 1: 2) );
const {ca_port: caPort, ca_name: caName, msp: mspName} = config[i];


var Fabric_Client = require('fabric-client');
var Fabric_CA_Client = require('fabric-ca-client');

//
var fabric_client = new Fabric_Client();
var fabric_ca_client = null;
var admin_user = null;
var member_user = null;
var store_path = path.join(__dirname, 'hfc-key-store/' + org);
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
    fabric_ca_client = new Fabric_CA_Client(`http://localhost:${caPort}`, tlsOptions , `ca.${org}.example.com`, crypto_suite);

    // first check to see if the admin is already enrolled
    return fabric_client.getUserContext('admin', true);
}).then((user_from_store) => {
    if (user_from_store && user_from_store.isEnrolled()) {
        console.log('Successfully loaded admin from persistence');
        admin_user = user_from_store;
        return null;
    } else {
        // need to enroll it with CA server
        return fabric_ca_client.enroll({
          enrollmentID: 'admin',
          enrollmentSecret: 'adminpw'
        }).then((enrollment) => {
          console.log('Successfully enrolled admin user "admin"');
          return fabric_client.createUser(
              {username: 'admin',
                  mspid: mspName,
                  cryptoContent: { privateKeyPEM: enrollment.key.toBytes(), signedCertPEM: enrollment.certificate }
              });
        }).then((user) => {
          admin_user = user;
          return fabric_client.setUserContext(admin_user);
        }).catch((err) => {
          console.error('Failed to enroll and persist admin. Error: ' + err.stack ? err.stack : err);
          throw new Error('Failed to enroll admin');
        });
    }
}).then(() => {
    console.log('Assigned the admin user to the fabric client ::' + admin_user.toString());
}).catch((err) => {
    console.error('Failed to enroll admin: ' + err);
});
