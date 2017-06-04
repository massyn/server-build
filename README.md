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
* $ sudo ./configure_virtualhost.pl <enter the FQDN>

Each website will have a seperate directory.  Depending on where you stored your sites (the default is /wwwroot), the script will create a new directory, and configure Apache to use the site.
