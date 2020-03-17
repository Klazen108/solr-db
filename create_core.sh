#!/bin/sh

CORE_NAME=$1

# If you're running this on your own separate server, ensure these variables are correct!
solrdir=/opt/solr
coresdir=/var/solr/data
serverurl=http://localhost:8983/solr

CORE_DIR="$coresdir/$CORE_NAME"

echo "Creating and configuring core $CORE_NAME in path $CORE_DIR"

echo "Creating core"
#
$solrdir/bin/solr create -c $CORE_NAME

echo "Copying data import libraries to core"
#
mkdir $CORE_DIR/lib
cp -v $solrdir/dist/solr-dataimporthandler-*.jar $CORE_DIR/lib

echo "Copying data config for DIH"
#
cp -v core_config/solr-data-config.xml $CORE_DIR/conf

echo "Reloading core to pick up new library"
#
if ! curl -s -X GET $serverurl/admin/cores?action=RELOAD'&'core=$CORE_NAME; then
  echo "Failed to reload core."
  exit 1
fi

echo "Adding data import handler to core's configuration at /dataimport"
#
if ! curl -s -X POST -H 'Content-type:application/json' --data-binary '{
    "add-requesthandler":{
      "name":"/dataimport",
      "class":"solr.DataImportHandler",
      "defaults":{
        "config":"solr-data-config.xml"
      }
    }
  }' $serverurl/$CORE_NAME/config; then
  echo "Failed to configure data import handler."
  exit 2
fi

echo "Running script to create fields in core"
#
echo "Reading field configs from ./core_config/field-config.json"
# read json                         | for each in array           | escape quotes   | post add-field to server
cat ./core_config/field-config.json | ./jq --compact-output '.[]' | sed 's/"/\\"/g' | \
xargs -I '{}' -P 1 -t bash -c "curl -s -X POST -H 'Content-type:application/json' --data-binary '{\"add-field\":{}}' $serverurl/$CORE_NAME/schema"