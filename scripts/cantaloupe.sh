#!/bin/bash
echo "Installing Cantaloupe IIIF Image Server"

HOME_DIR=$1

if [ -f "$HOME_DIR/islandora/configs/variables" ]; then
  . "$HOME_DIR"/islandora/configs/variables
fi

if [ ! -f "$DOWNLOAD_DIR/cantaloupe.zip" ]; then
  echo "Downloading Cantaloupe"
  wget -q -O "$DOWNLOAD_DIR/cantaloupe.zip" "https://github.com/medusa-project/cantaloupe/releases/download/v3.3/Cantaloupe-3.3.zip"
fi

if [ ! -f "$DOWNLOAD_DIR/openjpeg-source.tar.gz" ]; then
  echo "Downloading OpenJPEG"
  wget -q -O "$DOWNLOAD_DIR/openjpeg-source.tar.gz" "https://github.com/uclouvain/openjpeg/archive/v2.1.2.tar.gz"
fi

apt-get -y -qq install liblcms2-dev
apt-get -y -qq install libpng-dev
apt-get -y -qq install libtiff-dev
apt-get -y -qq install cmake

tar -xvzf "$DOWNLOAD_DIR/openjpeg-source.tar.gz" -C /tmp 
mkdir "/tmp/openjpeg-2.1.2/build"
cd "/tmp/openjpeg-2.1.2/build"
cmake ..
make
make install
ldconfig

mkdir /opt/cantaloupe
mkdir /opt/cantaloupe/images
mkdir /var/log/cantaloupe
unzip "$DOWNLOAD_DIR/cantaloupe.zip" -d /opt/cantaloupe
cp "$HOME_DIR/islandora/configs/cantaloupe/cantaloupe.properties" "/opt/cantaloupe/cantaloupe.properties"
echo 'CATALINA_OPTS="${CATALINA_OPTS} -Dcantaloupe.config=/opt/cantaloupe/cantaloupe.properties"' >> /etc/default/tomcat8
chown -R tomcat8:tomcat8 /opt/cantaloupe
chown -R tomcat8:tomcat8 /var/log/cantaloupe
service tomcat8 restart
mv /opt/cantaloupe/Cantaloupe-3.3/Cantaloupe-3.3.war /var/lib/tomcat8/webapps/cantaloupe.war
