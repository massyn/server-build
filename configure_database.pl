#!/usr/bin/perl

# == Configure additional mySQL databases

use strict;
use MIME::Base64;

do './library.pl';
&log("Starting $0");

my $db = $ARGV[0];
if($db eq '')
{
        $db = &ask("Enter the database name");
}

# == before we do anything else, let's check the Ubuntu version
my $VER = &ubuntu_version();
if($VER eq 'unknown')
{
	die "Sorry, but this version of Ubuntu is not supported.";
}

# == manage the config
my $CONFIG = "/etc/server_build.cfg";
my %Q = &manage_config($CONFIG);

if($Q{ROLEDB} =~ /y/i)
{
	# == Let's check if we have a .myconfig.cfg file.  If not, define the root password first
	if(!-f '~/.mylogin.cnf')
	{
		print "Please provide the root password (once).  This will be encrypted in the .mylogin.cnf file\n";
		system("mysql_config_editor set --user=root --password");
	}
	
	if(!-f '~/.mylogin.cnf')
	{
		die "Something went wrong with the creation of the .mylogin.cnf file";	
	}
	
	my $user = $db;
	my $pass = &generate_password;

        system("echo \"create database $db\" |mysql");
        system("echo \"grant usage on *.* to $user\@localhost identified by '$pass'\" | mysql");
        system("echo \"grant all privileges on $db.* to $user\@localhost\" | mysql");
	
	print "STORE THESE CREDENTIALS SECURELY!\n";
	print "database : $db\n";
	print "username : $user\n";
	print "password : $pass\n";
}
else
{
	&log("This machine is not designated as a database server.  If you decide to change the role, update the config file $CONFIG");
}

sub generate_password
{
        my $p;
        for(my $k=0;$k<20;$k++)
        {
                $p .= chr(rand(255));
        }

        my $e = encode_base64($p);

        $e =~ s/[^a-zA-Z0-9]//g;

        return substr($e,0,14);
}
