#!/usr/bin/perl

# == Configure additional virtual hosts for Apache

use strict;
do './library.pl';
&log("Starting $0");

my $newsite = $ARGV[0];
my $usessl = $ARGV[1];

&log("Website : $newsite");
&log("Use SSL : $usessl");

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

if($Q{ROLEWEB} =~ /y/i)
{
	# == did we get a FQDN from the command line?
	if($newsite ne '')
	{	
		if(-d "$Q{WWWROOT}/$newsite")
		{
			&log("WARNING - can not create new site $newsite because the directory $Q{WWWROOT}/$newsite already exists");
		}
		else
		{
			mkdir "$Q{WWWROOT}/$newsite";
		}
	}
	
	# == put Let's Encrypt on the machine, if we need to use SSL
	if($usessl =~ /y/i)
	{
		# == clone Let's encrypt
		if(!-d "$ENV{HOME}/letsencrypt/")
		{
			system("git clone https://github.com/letsencrypt/letsencrypt ~/letsencrypt");
		}
		system("service apache2 stop");
		system("~/letsencrypt/letsencrypt-auto certonly --standalone -d $newsite --email $Q{ADMIN} --renew-by-default");
		if($? != 0)
		{
			print "\n";
			&log("WARNING - Let's Encrypt had a problem.  Press enter to continue.");
			<STDIN>;
		}
		system("service apache2 start");
	}	
	&www_virtualhost(\%Q);
}
else
{
	&log("This machine is not designated as a web server.  If you decide to change the role, update the config file $CONFIG");
}
&log("** All done! **");
