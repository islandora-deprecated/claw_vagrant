#!/bin/bash
echo "RUNNING POST-INSTALL COMMANDS"

HOME_DIR=$1
if [ -f "$HOME_DIR/islandora/configs/variables" ]; then
  . "$HOME_DIR"/islandora/configs/variables
fi

# Chown and chmod tomcat directory
chown -R tomcat8:tomcat8 /var/lib/tomcat8
chown -R tomcat8:tomcat8 /var/log/tomcat8
chmod -R g+w /var/lib/tomcat8

# Chown and chmod apache directory
chown -R www-data:www-data /var/www/html
chmod -R g+w /var/www/html

# Chown the home directory for good measure
chown -R ubuntu:ubuntu "$HOME_DIR"

# Fix FITS log
sed -i 's|log4j.appender.FILE.File=${catalina.home}/logs/fits-service.log|log4j.appender.FILE.File=/var/log/tomcat8/fits-service.log|g' /var/lib/tomcat8/webapps/fits/WEB-INF/classes/log4j.properties

# Copy solr config
sudo cp -R /var/www/html/drupal/web/modules/contrib/search_api_solr/solr-conf/6.x/* /var/solr/data/CLAW/conf
service solr restart

# Cycle tomcat
cd /var/lib/tomcat8
service tomcat8 restart

# Clear drupal cache
$DRUSH_CMD cache-rebuild
