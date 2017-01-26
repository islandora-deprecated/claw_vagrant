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
composer config -g github-oauth.github.com $GITHUB_TOKEN
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

$DRUSH_CMD en -y islandora
$DRUSH_CMD en -y islandora_collection

# Set default theme to bootstrap
$DRUSH_CMD -y en bootstrap
$DRUSH_CMD -y config-set system.theme default bootstrap


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

