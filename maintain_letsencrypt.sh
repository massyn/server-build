#!/bin/sh
cd ~/letsencrypt

sudo service apache2 stop
sudo ./letsencrypt/letsencrypt-auto renew
sudo service apache2 start
