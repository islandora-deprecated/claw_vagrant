#!/bin/bash

echo "Installing OpenSeadragon module and libraries"

HOME_DIR=$1

if [ -f "$HOME_DIR/islandora/configs/variables" ]; then
  . "$HOME_DIR"/islandora/configs/variables
fi

cd $DRUPAL_HOME
composer require drupal/libraries dev-3.x

cd "$DRUPAL_HOME/web/modules/contrib"
# Cloning openseadragon module down
git clone https://github.com/Islandora-CLAW/openseadragon.git
cd openseadragon
$DRUSH_CMD en -y openseadragon

# Copy openseadragon library definition to correct location.
cp openseadragon.json "$DRUPAL_HOME/web/sites/default/files/library-definitions/"

if [ ! -f "$DOWNLOAD_DIR/openseadragon-bin-${OPENSEADRAGON_VERSION}.tar.gz" ]; then
  wget -O "$DOWNLOAD_DIR/openseadragon-bin-${OPENSEADRAGON_VERSION}.tar.gz" "https://github.com/openseadragon/openseadragon/releases/download/v${OPENSEADRAGON_VERSION}/openseadragon-bin-${OPENSEADRAGON_VERSION}.tar.gz"
fi

cd "$DRUPAL_HOME/web/sites/"
if [ ! -d "all/assets/vendor" ]; then
  mkdir -p all/assets/vendor
fi

cp "$DOWNLOAD_DIR/openseadragon-bin-${OPENSEADRAGON_VERSION}.tar.gz" .
tar xf "$DOWNLOAD_DIR/openseadragon-bin-${OPENSEADRAGON_VERSION}.tar.gz" -C "$DRUPAL_HOME/web/sites/all/assets/vendor"
cd "$DRUPAL_HOME/web/sites/all/assets/vendor"
mv "openseadragon-bin-${OPENSEADRAGON_VERSION}" openseadragon

