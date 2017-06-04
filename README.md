# server-build

A set of scripts used to build a standard, hardened Linux based web server

## How to use
* Install a fresh Ubuntu server image (Currently, 17.04)
* $ git clone https://github.com/massyn/server-build.git
* $ cd server-build
* $ sudo ./build-it.pl

## Operations
### Add a website
* Update your DNS entry for the website to point to your server.
* $ sudo ./configure_virtualhost.pl newsite.example.com

Each website will have a seperate directory.  Depending on where you stored your sites (the default is /wwwroot), the script will create a new directory, and configure Apache to use the site.

### Configure a website to use SSL
By default, the solution will check for the implementation of Let's Encrypt.  If a Let's Encrypt certificate is found, the configure_virtualhost.pl script will configure it automatically.

* $ git clone https://github.com/letsencrypt/letsencrypt
* $ ./letsencrypt/letsencrypt-auto certonly --standalone -d newsite.example.com --email youremail@ddress.com --renew-by-default

OPPORTUNITY - Integrate these commands into the configure_virtualhost.pl command, to make a seamless experience

TODO

### Add a new database
TODO

### Backups
No solution is complete without backups.
TODO

