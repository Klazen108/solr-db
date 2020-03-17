#!/bin/sh

# parameters passed
CORE_NAME=$1

echo "Starting solr so we can configure"
start-local-solr

./create_core.sh $CORE_NAME

echo "Stopping configuration instance"
stop-local-solr

echo "Copying configured cores to maintain across volume clear"
cp -r /var/solr/data /tmp/data