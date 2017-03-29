#!/bin/bash
echo "Installing FITS Web Service and FITS"

HOME_DIR=$1

if [ -f "$HOME_DIR/islandora/configs/variables" ]; then
  . "$HOME_DIR"/islandora/configs/variables
fi

if [ ! -f "$DOWNLOAD_DIR/fits-$FITS_VERSION.zip" ]; then
  echo "Downloading FITS"
  wget -q -O "$DOWNLOAD_DIR/fits-$FITS_VERSION.zip" "http://projects.iq.harvard.edu/files/fits/files/fits-$FITS_VERSION.zip"
fi

if [ ! -f "$DOWNLOAD_DIR/fits-$FITS_WS_VERSION.war" ]; then
  echo "Downloading FITS Web Service"
  wget -q -O "$DOWNLOAD_DIR/fits-$FITS_WS_VERSION.war" "http://projects.iq.harvard.edu/files/fits/files/fits-$FITS_WS_VERSION.war"
fi

unzip -q "$DOWNLOAD_DIR/fits-$FITS_VERSION.zip" -d /opt
mv /opt/fits-$FITS_VERSION /opt/fits
chown tomcat8:tomcat8 /opt/fits

cp "$DOWNLOAD_DIR/fits-$FITS_WS_VERSION.war" /var/lib/tomcat8/webapps/fits.war
chown tomcat8:tomcat8 /var/lib/tomcat8/webapps/fits.war

sed -i '$ifits.home=/opt/fits' /etc/tomcat8/catalina.properties
sed -i '$ishared.loader=${fits.home}/lib/*.jar' /etc/tomcat8/catalina.properties

service tomcat8 restart
