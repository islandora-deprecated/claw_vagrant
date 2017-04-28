#!/bin/bash
echo "Deploying Karaf Configuration"

HOME_DIR=$1
if [ -f "$HOME_DIR/islandora/configs/variables" ]; then
  . "$HOME_DIR"/islandora/configs/variables
fi

if [ ! -f "$KARAF_DIR/etc/org.fcrepo.camel.indexing.triplestore.cfg" ]; then
  # Wait a minute for Karaf to finish starting up
  echo  "$KARAF_DIR/etc/org.fcrepo.camel.indexing.triplestore.cfg doesn't exist, waiting a minute"
  sleep 60
fi

if [ -f "$KARAF_DIR/etc/org.fcrepo.camel.indexing.triplestore.cfg" ]; then
  # Update fcrepo triplestore indexing config
  sed -i 's|triplestore.baseUrl=http://localhost:8080/fuseki/test/update|triplestore.baseUrl=http://localhost:8080/bigdata/namespace/islandora/sparql|' "$KARAF_DIR/etc/org.fcrepo.camel.indexing.triplestore.cfg"
  sed -i 's|input.stream=broker:topic:fedora|input.stream=activemq:queue:fcrepo-indexing-triplestore|' "$KARAF_DIR/etc/org.fcrepo.camel.indexing.triplestore.cfg"
  sed -i 's|triplestore.reindex.stream=broker:queue:triplestore.reindex|triplestore.reindex.stream=activemq:queue:triplestore.reindex|' "$KARAF_DIR/etc/org.fcrepo.camel.indexing.triplestore.cfg"
else
  echo "$KARAF_DIR/etc/org.fcrepo.camel.indexing.triplestore.cfg still doesn't exist, this is an ERROR!"
fi

if [ -f "$KARAF_DIR/etc/ca.islandora.alpaca.connector.broadcast.cfg" ]; then
  # Update islandora broadcaster config
  sed -i 's|input.stream=broker:queue:islandora-connector-broadcast|input.stream=activemq:queue:islandora-connector-broadcast|' "$KARAF_DIR/etc/ca.islandora.alpaca.connector.broadcast.cfg"
else
  echo "$KARAF_DIR/etc/ca.islandora.alpaca.connector.broadcast.cfg still doesn't exist, this is an ERROR!"
fi

if [ -f "$KARAF_DIR/etc/ca.islandora.alpaca.indexing.triplestore.cfg" ]; then
  # Update islandora triplestore indexer config
  sed -i 's|input.stream=broker:queue:islandora-indexing-triplestore|input.stream=activemq:queue:islandora-indexing-triplestore|' "$KARAF_DIR/etc/ca.islandora.alpaca.indexing.triplestore.cfg"
  sed -i 's|triplestore.baseUrl=http://localhost:8080/bigdata/namespace/kb/sparql|triplestore.baseUrl=http://localhost:8080/bigdata/namespace/islandora/sparql|' "$KARAF_DIR/etc/ca.islandora.alpaca.indexing.triplestore.cfg"
  sed -i 's|drupal.username=|drupal.username=admin|' "$KARAF_DIR/etc/ca.islandora.alpaca.indexing.triplestore.cfg"
  sed -i 's|drupal.password=|drupal.password=islandora|' "$KARAF_DIR/etc/ca.islandora.alpaca.indexing.triplestore.cfg"
else
  echo "$KARAF_DIR/etc/ca.islandora.alpaca.indexing.triplestore.cfg still doesn't exist, this is an ERROR!"
fi
