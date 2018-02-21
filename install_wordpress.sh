#!/bin/sh

. /etc/server_build.cfg

if [ -z "$1" ]; then
  echo 'You must provide the name of the website domain where to install Wordpress'
  exit 1
fi

if [ !-d "$WWWROOT/$1/www"]; then
  echo 'The directory does not exist.  Maybe you need to create the website first with ./configure_virtualhost.pl'
  exit 1
fi

curl https://wordpress.org/latest.tar.gz | tar -zxvC /tmp

mv /tmp/wordpress/* $WWWROOT/$1/www/
