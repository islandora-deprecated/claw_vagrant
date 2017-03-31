#!/bin/sh

echo "Installing LAMP server packages"

PACKAGES="libwrap0 ssl-cert libterm-readkey-perl mysql-client libdbi-perl libmysqlclient20 mysql-client-core-5.7 mysql-common apache2 mysql-server mysql-server-core-5.7 tcpd libaio1 mysql-server libdbd-mysql-perl libhtml-template-perl php7.0 php7.0-dev libapache2-mod-php7.0 php7.0-mbstring"

apt-get -qq install -y $PACKAGES

usermod -a -G www-data ubuntu

chown -R ubuntu:ubuntu islandora

sed -i '$idate.timezone=America/Toronto' /etc/php/7.0/cli/php.ini

# Have Apache listen on port 8000
sed -i 's|Listen 80|Listen 8000|g' /etc/apache2/ports.conf
sed -i 's|<VirtualHost \*\:80>|<VirtualHost \*\:8000>|' /etc/apache2/sites-enabled/000-default.conf

#Bind external port for mysql
printf "\n[mysqld]\nbind-address = 0.0.0.0" >> /etc/mysql/my.cnf

#Grant permissions to root user
mysql --defaults-extra-file=/etc/mysql/debian.cnf -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'islandora';
FLUSH PRIVILEGES;"

sudo service mysqld restart
