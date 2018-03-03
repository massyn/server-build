#!/usr/bin/perl

use strict;
do './library.pl';
&log("Starting $0");

# == manage the config
my $CONFIG = "/etc/server_build.cfg";
my %Q = &manage_config($CONFIG);

# == this process relies on the .mylogin.cnf file to be available.  If it's not there, ask for it, else we die.
if(!-f "$ENV{HOME}/.mylogin.cnf")
{
        print "Please provide the root password (once).  This will be encrypted in the .mylogin.cnf file\n";
        system("mysql_config_editor set --user=root --password");
}

if(!-r "$ENV{HOME}/.mylogin.cnf")
{
        die "Something went wrong with the creation of the .mylogin.cnf file";	
}
        
&log("Saving backups to $Q{BACKUP}");

if(!-d $Q{BACKUP})
{
        &log("Creating the backup directory");
        mkdir($Q{BACKUP});
}

# == backup databases
foreach my $db (`echo show databases |mysql | grep -v Database | grep -v performance_schema | grep -v information_schema`)
{
        chomp($db);
        &log("Backing up database ==> $db");

        system("/usr/bin/mysqldump $db |gzip -c > $Q{BACKUP}/db_$db.sql.gz");
}

# == backup websites
foreach my $www (`ls $Q{WWWROOT}`)
{
        chomp($www);
        &log("Backing up website ==> $www");
        system("/bin/tar -czf $Q{BACKUP}/www_$www.tar.gz $Q{WWWROOT}/$www/www/.");
}
