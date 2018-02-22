#!/bin/sh

/usr/sbin/service apache2 stop
../letsencrypt/letsencrypt-auto renew
/usr/sbin/service apache2 start
