#!/bin/bash
fabric-ca-client enroll -u http://admin:adminpw@ca.distr.tracelabel.com:7054
fabric-ca-client register -u http://ca.distr.tracelabel.com:7054 --id.name peer0.tracelabel.com --id.type peer --id.affiliation distributors1 -M ./peer0.tracelabel.com
