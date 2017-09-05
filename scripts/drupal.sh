#!/bin/bash

echo "Installing Drupal."

HOME_DIR=$1

if [ -f "$HOME_DIR/islandora/configs/variables" ]; then
  . "$HOME_DIR"/islandora/configs/variables
fi

cd "$HOME_DIR"

# Drush and drupal deps
apt-get -y -qq install php7.0-gd php7.0-xml php7.0-mysql php7.0-curl php7.0-json
a2enmod rewrite
service apache2 reload
cd /var/www/html

# Download Drupal
git clone https://github.com/Islandora-CLAW/drupal-project drupal
cd "$DRUPAL_HOME"
composer install

# Setup drush and drupal console aliases
touch "$HOME_DIR/.bash_aliases"
echo "alias drush=\"$DRUSH_CMD\"" >> "$HOME_DIR/.bash_aliases"
echo "alias drupal=\"$DRUPAL_CMD\"" >> "$HOME_DIR/.bash_aliases"

# Do the install
cd "$DRUPAL_HOME/web"
$DRUSH_CMD si -y --db-url=mysql://root:islandora@localhost/drupal8 --site-name=Islandora-CLAW
$DRUSH_CMD user-password admin --password=islandora

# Set document root
sed -i 's|DocumentRoot /var/www/html$|DocumentRoot /var/www/html/drupal/web|' /etc/apache2/sites-enabled/000-default.conf

# Set override for drupal directory
# TODO Don't do this in main apache conf
sed -i '$i<Directory /var/www/html/drupal/web>' /etc/apache2/apache2.conf
sed -i '$i\\tOptions Indexes FollowSymLinks' /etc/apache2/apache2.conf
sed -i '$i\\tAllowOverride All' /etc/apache2/apache2.conf
sed -i '$i\\tRequire all granted' /etc/apache2/apache2.conf
sed -i '$i</Directory>' /etc/apache2/apache2.conf

# Torch the default index.html
rm /var/www/html/index.html

## Trusted Host Settings
cat >> "$DRUPAL_HOME"/web/sites/default/settings.php <<EOF
\$settings['trusted_host_patterns'] = array(
'^localhost$',
);
EOF

# Cycle apache
service apache2 restart

#Enable Core modules
$DRUSH_CMD en -y rdf
$DRUSH_CMD en -y responsive_image
$DRUSH_CMD en -y syslog
$DRUSH_CMD en -y serialization
$DRUSH_CMD en -y basic_auth
$DRUSH_CMD en -y rest
$DRUSH_CMD en -y simpletest

# Islandora dependencies

# REST UI
$DRUSH_CMD en -y restui

# Media entity ecosystem
$DRUSH_CMD en -y media_entity

$DRUSH_CMD en -y media_entity_image

# Devel
$DRUSH_CMD -y en devel

# Apache Solr
## https://www.drupal.org/node/2613470
$DRUSH_CMD -y pm-uninstall search
$DRUSH_CMD en -y search_api
$DRUSH_CMD en -y search_api_solr
$DRUSH_CMD en -y search_api_solr_defaults
$DRUSH_CMD en -y facets

# Set default solr server to point to CLAW core
$DRUSH_CMD -y config-set search_api.server.default_solr_server backend_config.connector_config.core CLAW

# Set default theme to carapace (and download dependencies, will composer-ize later)
cd $DRUPAL_HOME
composer require "drupal/adaptivetheme:^2.0" "drupal/at_tools:^2.0" "drupal/layout_plugin:^1.0@alpha"
$DRUSH_CMD en -y at_tools
$DRUSH_CMD en -y layout_plugin
mkdir /var/www/html/drupal/web/themes/custom
git clone https://github.com/Islandora-CLAW/carapace /var/www/html/drupal/web/themes/custom/carapace
chown -R www-data:www-data /var/www/html/drupal/web/themes/custom/carapace
$DRUSH_CMD en -y carapace
$DRUSH_CMD -y config-set system.theme default carapace

# Islandora CLAW modules
$DRUSH_CMD en -y islandora
$DRUSH_CMD en -y islandora_collection
$DRUSH_CMD en -y islandora_image

#If libraries folder does not exist, create
if [ ! -d "$DRUPAL_HOME/web/libraries" ]; then
  mkdir "$DRUPAL_HOME/web/libraries"
fi
cd $DRUPAL_HOME/web/libraries || exit

# D3.js - WebProfiler dependency
if [ ! -d "d3" ]; then
  mkdir "d3"
fi
cd "d3"
wget https://github.com/d3/d3/releases/download/v4.4.4/d3.zip
unzip d3.zip
rm *.zip

# highlightjs - WebProfiler dependency
# WebProfiler expects the js file to be named highlight.pack.js
# More info: https://www.drupal.org/node/2635734
cd ".."
wget https://github.com/isagalaev/highlight.js/archive/9.9.0.zip
unzip 9.9.0.zip

mv "highlight.js-9.9.0" "highlightjs"
cd "highlightjs"
cp -R src/* ./
mv "highlight.js" "highlight.pack.js"
cd ".."
rm *.zip

# Permissions
chown -R www-data:www-data "$DRUPAL_HOME"
chmod -R g+w "$DRUPAL_HOME"
chmod -R 755 "$DRUPAL_HOME"/web/libraries
usermod -a -G www-data ubuntu

# Add files and config for JWT Tokens
mkdir "$HOME_DIR/auth"
openssl genrsa -out "$HOME_DIR/auth/private.key" 2048
openssl rsa -pubout -in "$HOME_DIR/auth/private.key" -out "$HOME_DIR/auth/public.key"
$DRUSH_CMD config-import -y --partial --source="$HOME_DIR/islandora/configs/drupal/"
