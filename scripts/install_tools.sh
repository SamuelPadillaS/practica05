#!/bin/bash

set -x

#Variables de configuración
PHPMYADMIN_APP_PASSWORD=password
STATS_USER=usuario
STATS_PASSWORD=usuario



#Instalación de phpMyAdmin

#Configuramos las resouestas para hacer uan instalación desatendida de phpMyAdmin

echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2" | debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-password-confirm password $PHPMYADMIN_APP_PASSWORD" | debconf-set-selections

#Instalamos phpmyAdmin

apt install phpmyadmin php-mbstring php-zip php-gd php-json php-curl -y

#Instalación de Aminer
wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php

#Creamos un directorio para Adminer

mkadir -p /var/www/html/adminer


#Renombramos el archivo

mv adminer -4.8.1-mysql.php /var/www/html/adminer/index.php



#Instalación de GoAccess

#Analizamos  el repositorio de GoAccess

echo "deb http://deb.goaccess.io/ $(lsb_release -cs) main" > /etc/apt/source.list.d/goaccess.list

#Añadimos la clave publica de GoAccess 

wget -O - https://deb.goaccess.io/gnugpg.key | sudo apt-key add -

#Actualizamos lso repositorios

apt update

#Instalamos GoAccess

sudo apt-get install goaccess -y 

#Creamos el directorio stats

mkdir -p  /var/www/html/stats

#Modificamos el propietario y el grupo del directorio /var/www/html

chown www-data:www-data /var/www/html -R

#Ejecutamos GoAccess en sefundo plano 
goaccess /var/log/apache2/access.log -o /var/www/html/stats/index.html --log-format=COMBINED --real-time-html --daemonize



#Control de acceso a un directorio con autenticación básica

#Creamos un directorio para guardar el archivo de claves

mkdir /etc/apache2/claves

#Creamos un usuario/password en un artículo .htpasswd

htpasswd -bc /etc/apache2/claves/.htpasswd $STATS_USER $STATS_PASSWORD

#Copiamos el archivo de configuración de apache

cp ../conf/000-default.conf /etc/apache2/sites-available

#Reiniciamos el servicio de Apache

systemctl restart apache2



#Control de acceso a un directorio con .htaccess

#Creamos un nusuario/password en un archivo .htpasswd
htpasswd -bc /etc/apache2/claves/.htpasswd $STATS_USER $STATS_PASSWORD

#Copiamos el archivo htaccess en www/var/html/
cp ../htaccess/htaccess /var/www/html/stats/.htaccess

#Copiamos el archivo de configuración de Apache
cp ../conf/000-default-htaccess.conf /etc/apache2/sites-available/000-default.conf

#Reiniciamos el servicio de Apache
systemctl restart apache2
