#!/bin/sh
# Crayfish
echo "Installing Crayfish"

HOME_DIR=$1

if [ -f "$HOME_DIR/islandora/configs/variables" ]; then
  . "$HOME_DIR"/islandora/configs/variables
fi

cd /var/www/html
git clone https://github.com/Islandora-CLAW/Crayfish.git
cd Crayfish

for D in */; do
    (cd $D; composer install)
    cp "$HOME_DIR/islandora/configs/Syn/syn-settings.xml" $D
    if [ ! -f "$D/cfg/config.yaml" ]; then
      cp "$D/cfg/config.example.yaml" "$D/cfg/config.yaml"
    fi
    sed -i "s/level: NONE/level: DEBUG/" $D/cfg/config.yaml
    sed -i "s/enable: false/enable: true/" $D/cfg/config.yaml
    sed -i "s/user: changeme/user: root/" $D/cfg/config.yaml
    sed -i "s/password: changeme/password: islandora/" $D/cfg/config.yaml
done

# Gemini
mysql -u "$MYSQL_USER" -p"$MYSQL_PASS" < "$HOME_DIR/islandora/configs/gemini.sql"

# Hypercube
apt-get -y -qq install tesseract-ocr

chown -R www-data:www-data .

cp "$HOME_DIR/islandora/configs/001-crayfish.conf" /etc/apache2/sites-enabled

service apache2 restart
