# server-build

A set of scripts used to build a standard, hardened Linux based web server.  This can typically be used for a company or a web development agency that would like to configure a LAMP server without having to worry about the basic config, and the basic security controls.

The solution is not complete yet.  It does work, but not all the security controls have been implemeneted yet.

# Known Issues
* When new versions of Ubuntu is relased, there are dependency issues with some of the packages.  Keeping backwards compatibility is problematic.  It is recommended that you do a fresh install onto a new VM, and install from scratch.  Migrating the website and database across should be fairly straight forward.

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

### Refresh the local repository
To update the local scripts
* $ cd ~/server-build
* $ git fetch origin
* $ git reset --hard origin/master

#### TODO
* Apache - Create a cron job to refresh the Let's Encrypt certificates
* PHP - hardening (in progress)
* Linux - hardening
* Linux - Allow to lock down the ssh system with 2FA (Google Authenticator)
* Linux - Allow the inclusion of a firewall (iptables)
* Linux - Allow the use of snort to act as a WAF
* Linux / mySQL - Perform daily backups
* Maintain any wordpress site that may be on the system (upgrade core, plugins, themes)
* Linux - Update the operating system with the latest patches
* Apache - run each website under it's own user id

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
Create a new database with a simple command line.  No sudo required.  A new password will be set.

* $ ./configure_database.pl databasename

#### Change a DB password
TODO

### Backups
TODO

# Design of the solution
## Linux
Ubuntu Linux is at the core of the entire solution.  Like with any unix installation, you should never use root.  It is also for that reason that the script would not allow you to run directly as root, as it will check if you've sudo'ed as root instead.
SSH is has also been hardened, to prevent unauthorized access.
## Apache
Apache has been configured to run with SSL, utilizing the free certificates from Let's encrypt.  You can copy your own certificates in if you so chose.
A www and logs directory is created in the home folder of the website, allowing the operator to quickly analyze any potential issue.
