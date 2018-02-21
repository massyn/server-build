#!/usr/bin/perl

# == Configure additional mySQL databases

use strict;
use DBI;
use MIME::Base64;

do './library.pl';
&log("Starting $0");

my $db = $ARGV[0];
if($db eq '')
{
        $db = &ask("Enter the database name");
}

# == check if we are running with a sudo'ed root
&check_sudo();
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
	my $rootpw = &ask("Enter the mySQL root password",'','');
	# == see if we can connect to the database with the root password provided
	my $dbh = DBI->connect("DBI:mysql:database=mysql;host=localhost",'root',$rootpw, {RaiseError => 0}) || die( $DBI::errstr);

	my $user = $db;
	my $pass = &generate_password;;

	&db($dbh,"create database $db");
	&db($dbh,"grant usage on *.* to $user\@localhost identified by \'$pass\'");
	&db($dbh,"grant all privileges on $db.* to adm${user}\@localhost");

	print "admin user name : $user\n";
	print "password : $pass\n";

	$dbh->disconnect();
}
else
{
	&log("This machine is not designated as a database server.  If you decide to change the role, update the config file $CONFIG");
}

sub db
{
        my ($dbh,$cmd) = @_;

        if($dbh->do($cmd))
        {
                print "success\n";
        }
        else
        {
                die "FAILED = $cmd\n";
        }
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
