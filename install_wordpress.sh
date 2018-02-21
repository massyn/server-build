#!/bin/sh

curl https://wordpress.org/latest.tar.gz | tar -zxvC /tmp

mv /tmp/wordpress/* /wwwroot/$1/www/
