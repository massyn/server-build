#!/bin/sh

if [ -z "$1" ]; then
  echo 'You must provide the name of the website domain where to install Wordpress'
fi

. /etc/server_build.cfg
curl https://wordpress.org/latest.tar.gz | tar -zxvC /tmp

mv /tmp/wordpress/* $WWWROOT/$1/www/
