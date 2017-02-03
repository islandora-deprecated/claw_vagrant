#!/bin/bash
echo "Installing API-X"

HOME_DIR=$1

if [ -f "$HOME_DIR/islandora/configs/variables" ]; then
  . "$HOME_DIR"/islandora/configs/variables
fi

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64

echo "Installing API-X"
$KARAF_CLIENT -f $KARAF_CONFIGS/apix.script
