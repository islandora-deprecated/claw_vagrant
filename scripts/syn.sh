#!/bin/sh
# Syn
echo "Building Syn"

HOME_DIR=$1

if [ -f "$HOME_DIR/islandora/configs/variables" ]; then
  . "$HOME_DIR"/islandora/configs/variables
fi

cd "$HOME_DIR"
git clone https://github.com/jonathangreen/Syn.git
cd Syn
chown -R ubuntu:ubuntu "$HOME_DIR/Syn"
sudo -u ubuntu ./gradlew build

cp build/libs/islandora-syn-*-all.jar /var/lib/tomcat8/lib/
sed -i 's|</Context>|    <Valve className="ca.islandora.syn.valve.SynValve"/>\n</Context>|g' /var/lib/tomcat8/conf/context.xml
cp "$HOME_DIR/islandora/configs/Syn/web.xml" /var/lib/tomcat8/webapps/fcrepo/WEB-INF/web.xml
cp "$HOME_DIR/islandora/configs/Syn/syn-settings.xml" /var/lib/tomcat8/conf/syn-settings.xml

service tomcat8 restart
