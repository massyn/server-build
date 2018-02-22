#!/bin/sh
cd ~/letsencrypt

/usr/sbin/service apache2 stop
./letsencrypt/letsencrypt-auto renew
/usr/sbin/service apache2 start
