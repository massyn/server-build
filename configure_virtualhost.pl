#!/usr/bin/perl

# == Configure additional virtual hosts for Apache

use strict;
do './library.pl';
&log("Starting $0");

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

&www_virtualhost(\%Q);
