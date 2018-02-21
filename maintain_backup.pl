#!/usr/bin/perl

use strict;
do './library.pl';
&log("Starting $0");

# == manage the config
my $CONFIG = "/etc/server_build.cfg";
my %Q = &manage_config($CONFIG);

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

        system("mysqldump $db > $Q{BACKUP}/db_$db.sql");
}

# == backup websites
foreach my $www (`ls $Q{WWWROOT}`)
{
        chomp($www);
        &log("Backing up website ==> $www");
        system("tar -czvf $Q{BACKUP}/www_$www.tar $Q{WWWROOT}/$www");
}
