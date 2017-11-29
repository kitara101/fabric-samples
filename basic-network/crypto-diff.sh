#!/bin/sh

CRYPTO_DIR=./crypto-config
PREF=./_crypto_
ORIGS=${PREF}origs
GENS=${PREF}gens
DUPS=${PREF}dups
DIFF=${PREF}diff

find $CRYPTO_DIR > $ORIGS
rm -rf $CRYPTO_DIR
#./generate.sh
cryptogen generate --config=./crypto-config.yaml
find $CRYPTO_DIR > $GENS
sort $ORIGS $GENS | uniq -d > $DUPS

sort $ORIGS $DUPS | uniq -u | sed -e "s/^/< /" > $DIFF
sort $GENS $DUPS | uniq -u | sed -e "s/^/> /" >> $DIFF

mv $DIFF ./_diff
#rm ${PREF}*
