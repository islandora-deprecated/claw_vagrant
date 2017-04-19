#!/bin/bash
echo "Installing Composer"

HOME_DIR=$1

if [ -f "$HOME_DIR/islandora/configs/variables" ]; then
  . "$HOME_DIR"/islandora/configs/variables
fi

cd /tmp
curl -sS https://getcomposer.org/installer | php
php composer.phar install --no-progress
sudo mv composer.phar /usr/local/bin/composer

echo "Installing phpcs" 
cd $HOME
composer global require drupal/coder
composer global update drupal/coder --prefer-source
export PATH="$PATH:$HOME/.config/composer/vendor/bin"
echo 'export PATH="$PATH:$HOME/.config/composer/vendor/bin"' >> .bashrc
phpcs --config-set installed_paths $HOME/.config/composer/vendor/drupal/coder/coder_sniffer
