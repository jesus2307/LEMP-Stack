#!/bin/bash

#Declaración de todas las variables de utilidad
HTTPASSWD_DIR=/home/ubuntu
HTTPASSWD_USER=usuario
HTTPASSWD_PASSWD=usuario
IP_PRIVADA_MYSQL=172.31.61.19
# ------------------------------------------------------------------------------
# Instalación de la pila LAMP
# ------------------------------------------------------------------------------
# Habilitamos el modo de shell para mostrar los comandos que se ejecutan
set -x
# Actualizamos el repositorio
apt-get update
# inatalamos ngnix
apt-get install nginx -y
#iniciamos los modulos necesarios
apt-get install php-fpm php-mysql -y
#configuracion de php-fpm con este comando sustituimos la directiva ; cgi.fix_pathinfo = 1 por cgi.fix_pathinfo = 0. sed -i modifica y guarda y la 's' busca y remplaza.
sed -i " s /; cgi.fix_pathinfo = 1 / cgi.fix_pathinfo = 0 / " /etc/php/7.4/fpm/php.ini
#reiniciamos el servicio
systemctl reiniciar php7.4-fpm
#copiamos el archivo de configuracion de Ngnix
cp default /etc/nginx/sites-available/
#reiniciamos sercicio ngnix
systemctl reiniciar nginx

#----------------------
#INSTALACIÓN PHPMYADMIN|
#----------------------
#Instalamos la utilidad unzip
apt install unzip -y

#Descargamos el código fuente de phpMyAdmin 
cd /home/ubuntu
rm -rf phpMyAdmin-5.0.4-all-languages.zip
wget https://files.phpmyadmin.net/phpMyAdmin/5.0.4/phpMyAdmin-5.0.4-all-languages.zip

#Descomprimimos el archivo .zip
unzip phpMyAdmin-5.0.4-all-languages.zip

#Borramos el archivo .zip
rm -rf phpMyAdmin-5.0.4-all-languages.zip

#Movemos el directorio de phyMyAdmin al directorio /var/www/html
mv phpMyAdmin-5.0.4-all-languages/ /var/www/html/phpmyadmin

#Cambiamos al directorio de phpmyadmin para renombrar el archivo de configuración y configurarlo
cd /var/www/html/phpmyadmin
mv config.sample.inc.php config.inc.php
sed -i "s/localhost/$IP_PRIVADA_MYSQL/" /var/www/html/phpmyadmin/config.inc.php

#--------------------------
#INSTALACIÓN APLICACIÓN WEB| 
#--------------------------

#Vamos al directorio en el que se instalará la aplicación
cd /var/www/html

#Ejecutamos este comendo por si la carpeta de la aplicación existe, que sea eliminada
rm -rf iaw-practica-lamp

#Descargamos el repositorio
git clone https://github.com/josejuansanchez/iaw-practica-lamp.git

#Movemos el contenido del repositorio a la carpeta de apache
mv /var/www/html/iaw-practica-lamp/src/* /var/www/html/

#Quitamos el index.html 
rm -rf /var/www/html/index.html

#Quitamos los archivos que no necesitamos
rm -rf /var/www/html/index.html
rm -rf /var/www/html/iaw-practica-lamp/

#Cambiamos los permisos del directorio apache
chown www-data:www-data * -R

#Configuramos el archivo config.php
sed -i "s/localhost/$IP_PRIVADA_MYSQL/" /var/www/html/config.php
