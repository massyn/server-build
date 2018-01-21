# server-build

A set of scripts used to build a standard, hardened Linux based web server

## How to use
### DigitalOcean
When utilizing Virtual Machines from Digital Ocean, you need to perform the following steps.
* Create a new Virtual Machine image, with the Ubuntu 17.10 image.  As soon as the VM is created, DigitalOcean will email you the root password.
* As soon as you have logged on as root, create a new user account.  In this example, change "myuser" to the new user account.
$ adduser -a myuser
* Add the user to the sudo group
$ usermod -a -G sudo myuser
* Log out as root, and log on with the new user account

### Perform the install
* Install a fresh Ubuntu server image (Currently, 17.10)
* Log on with the account (not root!) that has sudo access
* $ git clone https://github.com/massyn/server-build.git
* $ cd server-build
* $ chmod +x *.pl
* $ sudo ./build-it.pl

#### TODO
* Create a cron job to refresh the Let's Encrypt certificates
* Allow to lock down the ssh system with 2FA (Google Authenticator)
* Allow the inclusion of a firewall (iptables)
* Allow the use of snort to act as a WAF
* Allow the automatic updating of patches
* Perform daily backups

## Operations
### Website
#### Add a website
* Update your DNS entry for the website to point to your server.
* $ sudo ./configure_virtualhost.pl newsite.example.com

Each website will have a seperate directory.  Depending on where you stored your sites (the default is /wwwroot), the script will create a new directory, and configure Apache to use the site.

#### Configure a website to use SSL
The script will utilize Let's Encrypt to setup a certificate for you.

* Update your DNS entry for the website to point to your server.
* $ sudo ./configure_virtualhost.pl newsite.example.com yes

### Databases
#### Add a new database
TODO

#### Change a DB password

### Backups
TODO

