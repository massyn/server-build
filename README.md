# server-build

A set of scripts used to build a standard, hardened Linux based web server.  This can typically be used for a company or a web development agency that would like to configure a LAMP server without having to worry about the basic config, and the basic security controls.

The solution is not complete yet.  It does work, but not all the security controls have been implemeneted yet.

## How to use
### DigitalOcean
When utilizing Virtual Machines from Digital Ocean, you need to perform the following steps.
* Create a new Virtual Machine image, with the Ubuntu 17.10 image.  As soon as the VM is created, DigitalOcean will email you the root password.
* As soon as you have logged on as root, create a new user account.  In this example, change "myuser" to the new user account.
`$ adduser -a myuser`
* Add the user to the sudo group
`$ usermod -a -G sudo myuser`
* Log out as root, and log on with the new user account

### Perform the install
* Install a fresh Ubuntu server image (Currently, 17.10)
* Create a new user, and add the user to the sudo group.
  * `adduser -a myuser`
  * `usermod -a -G sudo myuser`
* Log on with the account (not root!) that has sudo access
* Clone the code from Github, and execute the build
```bash
git clone https://github.com/massyn/server-build.git
cd server-build
chmod +x *.pl
chmod +x *.sh
sudo ./build-it.pl
./build-crontab.sh
```
* When asked, provide a password for the mySQL root instance
* When asked, install phpmyadmin on the apache system
* To change the timezone, execute `sudo timedatectl set-timezone Australia/Sydney` (changing Australia/Sydney to your timezone)

### Refresh the local repository
To update the local scripts
```bash
cd ~/server-build
git fetch origin
git reset --hard origin/master
```
#### TODO
* [ ] - Linux - hardening
  * [ ] - Allow to lock down the ssh system with 2FA (Google Authenticator)
  * [ ] - Allow the inclusion of a firewall (iptables)
  * [ ] - Blocking of excessive ssh connections (fail2ban ?)
* [ ] - mySQL - hardening
* [ ] - Apache - run each website under it's own user id

## Operations
### Operating System patching
The operating system needs to be patched regularly.  The plan is to do this automatically, but I've decided to remove the automatic update via crontab.  There are some packages that do not like to be upgraded via a crontab, since it needs user feedback.  Change Management is also bypassed, which is a problem, especially if you need to do proper testing before upgrading.
To upgrade the system, you can follow normal Ubuntu upgrade processes, or you can run the *maintain_os.sh* script.
* `sudo ./maintain_os.sh`
Once done, it would be a good idea to perform a reboot.

### Website
#### Add a website
* Update your DNS entry for the website to point to your server.
* Execute the *configure_virtualhost.pl* script to create the site.
* `sudo ./configure_virtualhost.pl newsite.example.com`

Each website will have a seperate directory.  Depending on where you stored your sites (the default is /wwwroot), the script will create a new directory, and configure Apache to use the site.

#### Configure a website to use SSL
The script will utilize Let's Encrypt to setup a certificate for you.

* Update your DNS entry for the website to point to your server.
* Execute the *configure_virtualhost.pl* script to create the site.
* `sudo ./configure_virtualhost.pl newsite.example.com yes`

#### Install a new Wordpress site
You can install a fresh Wordpress site using the latest wordpress code.  First, create the basic website using the steps above.  Once that's done, you can use this simple script to do to job.

* `./install_wordpress.sh newsite.example.com`

#### Upgrade Wordpress
All wordpress sites on the server will be automatically upgraded with the latest core, themes and plugins through a crontab once a day.  To execute the manual upgrade, you can run

* `./maintain_wordpress.pl`

### Databases
#### Add a new database
Create a new database with a simple command line.  No sudo required.  A new password will be set.

* `./configure_database.pl databasename`

#### Change a DB password
TODO

### Backups
Backups are scheduled through a cronjob.  When the server is built, you're given the option to choose where the backups will be stored.  Only the latest copy of backups are kept.  You are responsible for your own offsite copy of the backups.

# Design of the solution
## Linux
Ubuntu Linux is at the core of the entire solution.  Like with any unix installation, you should never use root.  It is also for that reason that the script would not allow you to run directly as root, as it will check if you've sudo'ed as root instead.
SSH is has also been hardened, to prevent unauthorized access.
Once a week the system will automatically apply all new patches through a cronjob.  
## Apache
Apache has been configured to run with SSL, utilizing the free certificates from Let's encrypt.  You can copy your own certificates in if you so chose.
A www and logs directory is created in the home folder of the website, allowing the operator to quickly analyze any potential issue.
Let's Encrypt certificates will be checked once a week through a cronjob to be refreshed if necessary.
## PHP
With the majority of sites running on PHP, some hardening of the PHP system is performed.
# Some key decisions
## Use of Snort
I've decided not to configure snort automatically.  Snort is a whole implementation on it's own, with many variables, and many things to consider.  This needs to be left to each web operator to configure themselves to their needs.
