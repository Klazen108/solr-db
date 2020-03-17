# SOLR DB Tester

The **SOLR DB Tester** package provides an environment for rapidly and repeatably testing a SOLR configuration which loads a core from a database, using the **DataImportHandler** request handler. It exposes the minimal configuration necessary to spin up a SOLR instance with a core backed by a SQL data source.

As the configuration involves some internal setup before actually performing the import, **you should NOT pull and run this image directly**. You should create your own image based off of this one. Read the **How to use** section for instructions on how to configure, build, and run your image.

# How to use

* Add your JDBC connection parameters and query to `core_config/solr-data-config.xml` (see section below for details)
* Add your fields to `core_config/field-config.json` (see section below for details)
* Build and run your image

```sh
docker build -t solr-demo .
docker run -p 8983:8983 -t solr-demo
```

* Visit http://localhost:8983/solr/# to view the admin console and confirm your core is there
* Hit http://localhost:8983/solr/CORE_NAME/dataimport?command=full-import to initiate a data import; progress can be viewed from the admin console

# solr-data-config.xml

The `solr-data-config.xml` file is directly used as the [DataImportHandler Request Handler configuration file](https://lucene.apache.org/solr/guide/6_6/uploading-structured-data-store-data-with-the-data-import-handler.html#configuring-dih). A quick intro to this file is provided in the prior link; a full documenation on the handler is available in the **Read More** section.

Here is an example `solr-data-config.xml` file which runs a query `select id,name from customers` against a *MySQL* database at localhost with username `root` and password `password`:
```xml
<dataConfig>
<dataSource type="JdbcDataSource" 
            driver="com.mysql.jdbc.Driver"
            url="jdbc:mysql://localhost:3306/mydb" 
            user="root" 
            password="password"/>
<document>
  <entity name="customer"  
    pk="id"
    query="select id,name from customers">
  </entity>
</document>
</dataConfig>
```

This configuration file provides no mapping of fields on the core; fields must be configured separately. Read on to the `field-config.json` section to learn more.

# field-config.json

Entries in `field-config.json` should be specified in the format expected by the [SOLR New Field API](https://lucene.apache.org/solr/guide/6_6/schema-api.html#SchemaAPI-AddaNewField), as an array of entries. For example, to add a field called `CUSTOMER_NAME` of type `string`, and `CUSTOMER_NO` as type `string`, your array would look like so:

```json
[
    {"name":"CUSTOMER_NAME","type":"string","stored":true},
    {"name":"CUSTOMER_NO","type":"string","stored":true}
]
```

Add as many fields as you would like in the JSON array. These map to the fields defined in your `solr-data-config.xml` document.

# Switching to a Production Instance

Once you are comfortable with the core setup, you can use the files in this package to apply the changes to your own instance. 

## One-time setup

Your production instance of SOLR will need the SQL drivers added once. Copy your drivers to `$SOLR_HOME/lib`.

## Per-core setup

Follow the steps provided in `create_core.sh`. You can copy that script and the `core_config` directory to the server and run it (provided [jq](https://stedolan.github.io/jq/) is installed). Make sure to modify the `solrdir` and `coresdir` variables if the paths are different, and modify the `server` variable if different (e.g. different port).

# Read more

* [Data Import Screen](https://lucene.apache.org/solr/guide/6_6/dataimport-screen.html) - for reviewing configuration inside SOLR, running import commands, and checking status
* [DataImportHandler Documentation](https://cwiki.apache.org/confluence/display/SOLR/DataImportHandler) - full DataImportHandler documentation
* [DataImportHandler Request Handler configuration file](https://lucene.apache.org/solr/guide/6_6/uploading-structured-data-store-data-with-the-data-import-handler.html#configuring-dih) - example DIH configuration file
* [SOLR New Field API](https://lucene.apache.org/solr/guide/6_6/schema-api.html#SchemaAPI-AddaNewField) - describes how new fields are added