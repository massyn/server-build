# server-build

A set of scripts used to build a standard, hardened Linux based web server

## How to use
### DigitalOcean
When utilizing Virtual Machines from Digital Ocean, you need to perform the following steps.
* Create a new Virtual Machine image, with the Ubuntu 17.04 image.  As soon as the VM is created, DigitalOcean will email you the root password.
* As soon as you have logged on as root, create a new user account.  In this example, change "myuser" to the new user account.
$ adduser -a myuser
* Add the user to the sudo group
$ usermod -a -G sudo myuser
* Log out as root, and log on with the new user account

### Perform the install
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
* Update your DNS entry for the website to point to your server.
* $ sudo ./configure_virtualhost.pl newsite.example.com yes

### Add a new database
TODO

### Backups
No solution is complete without backups.
TODO

