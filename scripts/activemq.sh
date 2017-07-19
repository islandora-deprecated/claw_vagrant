#!/bin/sh
echo "Installing ActiveMQ"

HOME_DIR=$1

if [ -f "$HOME_DIR/islandora/configs/variables" ]; then
  . "$HOME_DIR"/islandora/configs/variables
fi

if [ ! -f "$DOWNLOAD_DIR/apache-activemq-$ACTIVEMQ_VERSION-bin.tar.gz" ]; then
  echo "Downloading ActiveMQ"
  wget -q -O "$DOWNLOAD_DIR/apache-activemq-$ACTIVEMQ_VERSION-bin.tar.gz" "http://archive.apache.org/dist/activemq/5.14.5/apache-activemq-$ACTIVEMQ_VERSION-bin.tar.gz"
fi

cp "$DOWNLOAD_DIR/apache-activemq-$ACTIVEMQ_VERSION-bin.tar.gz" /tmp
tar -xzf "$DOWNLOAD_DIR/apache-activemq-$ACTIVEMQ_VERSION-bin.tar.gz" -C /opt
mv /opt/apache-activemq-$ACTIVEMQ_VERSION /opt/activemq
chown -hR ubuntu:ubuntu /opt/activemq

ln -snf /opt/activemq/bin/activemq /etc/init.d/activemq
update-rc.d activemq defaults
service activemq start
